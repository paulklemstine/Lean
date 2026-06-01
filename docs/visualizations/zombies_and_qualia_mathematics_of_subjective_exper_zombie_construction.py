def zombie_twin(agent, new_qualia_fn=None):
    if new_qualia_fn is None:
        new_qualia_fn = lambda s: None
    return {'functional': agent['functional'], 'qualia': new_qualia_fn}