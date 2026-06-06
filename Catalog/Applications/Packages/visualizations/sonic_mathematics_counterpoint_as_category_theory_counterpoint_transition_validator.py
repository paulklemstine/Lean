def is_valid_transition(src, tgt, motion):
    if tgt in ('unison', 'fifth') and motion in ('parallel', 'similar'):
        return False
    return True