import numpy as np
def softmax_to_max(x, beta):
    x_max = np.max(x)
    return x_max + (1.0/beta) * np.log(np.sum(np.exp(beta * (x - x_max))))