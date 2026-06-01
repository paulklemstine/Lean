def entanglement_depth(phi):
    if phi.kind in ('var', 'bot'): return 0
    if phi.kind == 'box': return entanglement_depth(phi.children[0])
    if phi.kind == 'imp':
        lhs, rhs = phi.children
        if lhs.kind == 'box' and lhs.children[0] == rhs:
            return entanglement_depth(rhs) + 1
        return max(entanglement_depth(lhs), entanglement_depth(rhs))
    return 0