/* SPDX-License-Identifier: MIT
 * avalonia-d C ABI — implemented by AvaloniaD.Host (DNNE native shim).
 * Handles are opaque. 0 is invalid. Strings are UTF-8, NUL-terminated.
 * Callbacks are cdecl. Pointers passed into callbacks are only valid during the call.
 */
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef uint64_t avd_handle;

enum {
    AVD_OK = 0,
    AVD_ERR = -1,
    AVD_NOT_INIT = -2,
    AVD_ALREADY_INIT = -3,
    AVD_BAD_HANDLE = -4,
    AVD_BAD_TYPE = -5,
    AVD_BAD_UTF8 = -6,
    AVD_UNSUPPORTED = -7
};

/* 0 = system, 1 = light, 2 = dark (ShadUI ThemeMode). */
enum { AVD_THEME_SYSTEM = 0, AVD_THEME_LIGHT = 1, AVD_THEME_DARK = 2 };

/* 0 = horizontal, 1 = vertical */
enum { AVD_HORIZONTAL = 0, AVD_VERTICAL = 1 };

typedef void (*avd_void_cb)(void* user);

const char* avd_version(void);
const char* avd_last_error(void);

int32_t avd_init(int32_t theme_mode);
int32_t avd_shutdown(void);
int32_t avd_switch_theme(int32_t theme_mode);

avd_handle avd_window_new(const char* title, int32_t width, int32_t height);
avd_handle avd_stack_new(int32_t orientation);
avd_handle avd_scroll_new(void);
avd_handle avd_button_new(const char* text);
avd_handle avd_text_new(const char* text);
avd_handle avd_textbox_new(const char* text);
avd_handle avd_checkbox_new(const char* text, int32_t is_checked);
avd_handle avd_separator_new(int32_t orientation);
avd_handle avd_card_new(void);
avd_handle avd_card_title_new(const char* text);
avd_handle avd_card_description_new(const char* text);

int32_t avd_panel_add(avd_handle parent, avd_handle child);
int32_t avd_card_set_header(avd_handle card, avd_handle header);
int32_t avd_card_set_footer(avd_handle card, avd_handle footer);
int32_t avd_window_set_content(avd_handle window, avd_handle content);

int32_t avd_set_text(avd_handle handle, const char* text);
int32_t avd_get_text(avd_handle handle, char* buf, int32_t cap);
int32_t avd_set_checked(avd_handle handle, int32_t value);
int32_t avd_get_checked(avd_handle handle);
int32_t avd_set_enabled(avd_handle handle, int32_t value);
int32_t avd_set_width(avd_handle handle, double width);
int32_t avd_set_height(avd_handle handle, double height);
int32_t avd_set_margin(avd_handle handle, double left, double top, double right, double bottom);
int32_t avd_set_padding(avd_handle handle, double left, double top, double right, double bottom);
int32_t avd_set_spacing(avd_handle handle, double spacing);
int32_t avd_set_font_size(avd_handle handle, double points);
int32_t avd_add_class(avd_handle handle, const char* class_name);

int32_t avd_on_click(avd_handle handle, avd_void_cb cb, void* user);
int32_t avd_on_text_changed(avd_handle handle, avd_void_cb cb, void* user);
int32_t avd_on_checked_changed(avd_handle handle, avd_void_cb cb, void* user);

/* Blocking UI loop. Returns when the window closes. */
int32_t avd_run(avd_handle window);

#ifdef __cplusplus
}
#endif
