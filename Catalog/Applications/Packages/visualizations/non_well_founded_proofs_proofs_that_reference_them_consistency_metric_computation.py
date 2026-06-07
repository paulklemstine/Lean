def consistency_metric(tree):
    if tree.type == 'axiom': return 0.0
    elif tree.type == 'mp': return max(consistency_metric(tree.left), consistency_metric(tree.right))
    elif tree.type == 'selfRef': return (1 + consistency_metric(tree.inner)) / 2
    elif tree.type == 'bot': return 1.0