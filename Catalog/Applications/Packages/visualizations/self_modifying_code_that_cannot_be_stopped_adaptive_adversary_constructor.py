def construct_adversary(classifier):
    return AdaptiveProgram(react=lambda pred: not pred)