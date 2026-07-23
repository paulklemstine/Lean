from typing import List, Optional, Tuple
import numpy as np

TOL = 1e-9


def _null_space(a: np.ndarray) -> np.ndarray:
    _, s, vh = np.linalg.svd(a)
    rank = int((s > TOL).sum())
    return vh[rank:].conj().T


def _affine_dependence(V: np.ndarray, support: List[int]) -> Optional[np.ndarray]:
    cols = np.array([np.append(V[i], 1.0) for i in support]).T
    ns = _null_space(cols)
    if ns.shape[1] == 0:
        return None
    u = np.zeros(len(V))
    for local, i in enumerate(support):
        u[i] = ns[local, 0]
    return u


def prune(V: np.ndarray, w: np.ndarray) -> Tuple[List[int], np.ndarray]:
    w = w.copy()
    d = V.shape[1]
    support = [i for i in range(len(w)) if w[i] > TOL]
    while len(support) > d + 1:
        u = _affine_dependence(V, support)
        if u is None:
            break
        thetas = [w[i] / (-u[i]) for i in support if u[i] < -TOL]
        if not thetas:
            u = -u
            thetas = [w[i] / (-u[i]) for i in support if u[i] < -TOL]
        theta = min(thetas)
        w = w + theta * u
        w[w < TOL] = 0.0
        support = [i for i in range(len(w)) if w[i] > TOL]
    return support, w
