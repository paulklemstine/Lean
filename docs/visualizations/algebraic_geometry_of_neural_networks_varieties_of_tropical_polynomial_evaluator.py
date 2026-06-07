def tropical_poly_eval(slopes, intercepts, x):
    terms = slopes[:, None] * x[None, :] + intercepts[:, None]
    return np.max(terms, axis=0)