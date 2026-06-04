def layer_norm(x, gamma=None, beta=None, eps=1e-12):
    mu = x.mean()
    var = ((x - mu) ** 2).mean()
    x_norm = (x - mu) / np.sqrt(var + eps)
    if gamma is not None and beta is not None:
        return gamma * x_norm + beta
    return x_norm