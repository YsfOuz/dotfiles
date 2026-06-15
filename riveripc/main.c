#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <wayland-client.h>
#include "protocols/river-status-unstable-v1-client-protocol.h"

#define MAX_OUTPUTS 16

struct output {
    struct wl_output               *wl;
    struct zriver_output_status_v1 *status;
    char                            name[256];
    bool                            got_name;

    uint32_t active;
    uint32_t occupied;
    uint32_t urgent;

    bool got_active;
    bool got_occupied;
    bool got_urgent;
};

struct state {
    struct wl_display               *display;
    struct wl_registry              *registry;
    struct zriver_status_manager_v1 *status_manager;

    struct output outputs[MAX_OUTPUTS];
    int           output_count;

    uint32_t river_version;
    bool     watch;
};

static struct state st;

/* ── printing ──────────────────────────────────────────────────────────────── */

static void print_tag_list(const char *label, uint32_t mask) {
    printf("%s:", label);
    for (int i = 0; i < 32; i++)
        if (mask & (1u << i))
            printf(" %d", i + 1);
    printf("\n");
}

static void print_output(struct output *out) {
    printf("output: %s\n", out->name[0] ? out->name : "(unknown)");
    print_tag_list("active",   out->active);
    print_tag_list("occupied", out->occupied);
    print_tag_list("urgent",   out->urgent);
    printf("\n");
    fflush(stdout);
}

static void try_print(struct output *out) {
    if (out->got_active && out->got_occupied && out->got_urgent)
        print_output(out);
}

/* ── river output status ───────────────────────────────────────────────────── */

static void handle_focused_tags(void *data,
        struct zriver_output_status_v1 *status, uint32_t tags) {
    struct output *out = data;
    out->active = tags;
    out->got_active = true;
    try_print(out);
}

static void handle_view_tags(void *data,
        struct zriver_output_status_v1 *status, struct wl_array *tags) {
    struct output *out = data;
    out->occupied = 0;
    uint32_t *tag;
    wl_array_for_each(tag, tags)
        out->occupied |= *tag;
    out->got_occupied = true;
    try_print(out);
}

static void handle_urgent_tags(void *data,
        struct zriver_output_status_v1 *status, uint32_t tags) {
    struct output *out = data;
    out->urgent = tags;
    out->got_urgent = true;
    try_print(out);
}

static void handle_layout_name(void *data,
        struct zriver_output_status_v1 *status, const char *name) {}

static void handle_layout_name_clear(void *data,
        struct zriver_output_status_v1 *status) {}

static const struct zriver_output_status_v1_listener output_status_listener = {
    .focused_tags      = handle_focused_tags,
    .view_tags         = handle_view_tags,
    .urgent_tags       = handle_urgent_tags,
    .layout_name       = handle_layout_name,
    .layout_name_clear = handle_layout_name_clear,
};

/* ── wl_output ─────────────────────────────────────────────────────────────── */

static void wl_output_name(void *data, struct wl_output *wl_output,
        const char *name) {
    struct output *out = data;
    strncpy(out->name, name, sizeof(out->name) - 1);
    out->got_name = true;
}

static void wl_output_geometry(void *data, struct wl_output *o, int32_t x,
        int32_t y, int32_t pw, int32_t ph, int32_t sp, const char *make,
        const char *model, int32_t transform) {}
static void wl_output_mode(void *data, struct wl_output *o, uint32_t flags,
        int32_t w, int32_t h, int32_t r) {}
static void wl_output_done(void *data, struct wl_output *o) {}
static void wl_output_scale(void *data, struct wl_output *o, int32_t f) {}
static void wl_output_description(void *data, struct wl_output *o,
        const char *d) {}

static const struct wl_output_listener output_listener = {
    .geometry    = wl_output_geometry,
    .mode        = wl_output_mode,
    .done        = wl_output_done,
    .scale       = wl_output_scale,
    .name        = wl_output_name,
    .description = wl_output_description,
};

/* ── registry ──────────────────────────────────────────────────────────────── */

static void registry_global(void *data, struct wl_registry *registry,
        uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, wl_output_interface.name) == 0
            && st.output_count < MAX_OUTPUTS) {
        struct output *out = &st.outputs[st.output_count++];
        uint32_t bind_ver = version < 4 ? version : 4;
        out->wl = wl_registry_bind(registry, name,
                &wl_output_interface, bind_ver);
        if (bind_ver >= 4)
            wl_output_add_listener(out->wl, &output_listener, out);
    } else if (strcmp(interface, zriver_status_manager_v1_interface.name) == 0) {
        st.river_version = version < 4 ? version : 4;
        st.status_manager = wl_registry_bind(registry, name,
                &zriver_status_manager_v1_interface, st.river_version);
    }
}

static void registry_global_remove(void *data, struct wl_registry *registry,
        uint32_t name) {}

static const struct wl_registry_listener registry_listener = {
    .global        = registry_global,
    .global_remove = registry_global_remove,
};

/* ── main ──────────────────────────────────────────────────────────────────── */

static void usage(const char *argv0) {
    fprintf(stderr,
            "usage: %s -t [-w] [-o <output>]\n"
            "  -t, --tags          print tag status\n"
            "  -w, --watch         watch for changes\n"
            "  -o, --output <name> filter to a specific output\n",
            argv0);
}

int main(int argc, char *argv[]) {
    bool        tags_mode     = false;
    const char *target_output = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-t") == 0 || strcmp(argv[i], "--tags") == 0) {
            tags_mode = true;
        } else if (strcmp(argv[i], "-w") == 0
                || strcmp(argv[i], "--watch") == 0) {
            st.watch = true;
        } else if (strcmp(argv[i], "-o") == 0
                || strcmp(argv[i], "--output") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "riveripc: %s requires an output name\n",
                        argv[i]);
                return 1;
            }
            target_output = argv[++i];
        } else {
            usage(argv[0]);
            return 1;
        }
    }

    if (!tags_mode) {
        usage(argv[0]);
        return 1;
    }

    st.display = wl_display_connect(NULL);
    if (!st.display) {
        fprintf(stderr, "riveripc: failed to connect to Wayland display\n");
        return 1;
    }

    st.registry = wl_display_get_registry(st.display);
    wl_registry_add_listener(st.registry, &registry_listener, NULL);
    wl_display_roundtrip(st.display);  /* bind globals           */
    wl_display_roundtrip(st.display);  /* receive wl_output.name */

    if (!st.status_manager) {
        fprintf(stderr, "riveripc: compositor does not support "
                        "zriver_status_manager_v1\n");
        wl_display_disconnect(st.display);
        return 1;
    }

    bool any = false;
    for (int i = 0; i < st.output_count; i++) {
        struct output *out = &st.outputs[i];

        if (target_output != NULL
                && (!out->got_name || strcmp(out->name, target_output) != 0))
            continue;

        if (st.river_version < 2)
            out->got_urgent = true;

        out->status = zriver_status_manager_v1_get_river_output_status(
                st.status_manager, out->wl);
        zriver_output_status_v1_add_listener(out->status,
                &output_status_listener, out);
        any = true;
    }

    if (!any) {
        fprintf(stderr, target_output
                ? "riveripc: output '%s' not found\n"
                : "riveripc: no outputs available\n",
                target_output);
        wl_display_disconnect(st.display);
        return 1;
    }

    wl_display_roundtrip(st.display);

    if (!st.watch) {
        wl_display_disconnect(st.display);
        return 0;
    }

    while (wl_display_dispatch(st.display) != -1);

    wl_display_disconnect(st.display);
    return 0;
}
