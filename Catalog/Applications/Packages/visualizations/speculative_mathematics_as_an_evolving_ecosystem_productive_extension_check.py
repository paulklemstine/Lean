def is_productive_extension(base_a, base_t, base_c, ext_a, ext_t, ext_c) -> bool:
    if not (ext_a >= base_a and ext_t >= base_t and ext_c >= base_c):
        return False
    return ext_c * ext_t * base_a > base_c * base_t * ext_a