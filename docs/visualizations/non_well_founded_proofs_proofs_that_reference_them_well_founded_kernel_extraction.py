def wf_kernel(tree):
    if tree.type == 'axiom': return tree
    elif tree.type == 'mp': return MP(wf_kernel(tree.left), wf_kernel(tree.right), tree.p, tree.q)
    elif tree.type == 'selfRef': return Axiom(tree.p)
    elif tree.type == 'bot': return tree