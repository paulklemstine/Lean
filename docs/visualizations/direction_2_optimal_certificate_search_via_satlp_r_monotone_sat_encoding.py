def encode_monotone_sat(vertices, edges):
    var_map = {v: i+1 for i, v in enumerate(sorted(vertices))}
    clauses = [[var_map[v] for v in sorted(e)] for e in edges]
    lines = [f"p cnf {len(var_map)} {len(clauses)}"]
    for c in clauses:
        lines.append(' '.join(map(str, c)) + ' 0')
    return '
'.join(lines), var_map