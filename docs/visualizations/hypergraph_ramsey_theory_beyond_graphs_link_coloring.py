def link_coloring(n, r, coloring, vertex):
    def link(S):
        if len(S) != r or vertex in S:
            return False
        return coloring(S | frozenset([vertex]))
    return link