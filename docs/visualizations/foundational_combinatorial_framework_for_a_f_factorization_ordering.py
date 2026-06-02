def selberg_lt(s1, s2) -> bool:
    return s1.d < s2.d or (s1.d == s2.d and s1.q < s2.q)