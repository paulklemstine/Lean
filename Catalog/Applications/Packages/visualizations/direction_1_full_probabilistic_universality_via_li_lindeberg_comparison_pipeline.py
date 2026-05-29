import numpy as np

def tropical_margin(W):
    n = W.shape[0]
    if n < 2: return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))

def ks_distance(s1, s2):
    combined = np.sort(np.unique(np.concatenate([s1, s2])))
    c1 = np.searchsorted(np.sort(s1), combined, side="right") / len(s1)
    c2 = np.searchsorted(np.sort(s2), combined, side="right") / len(s2)
    return float(np.max(np.abs(c1 - c2)))

rng = np.random.default_rng(42)
for n in [5, 10, 20, 50]:
    m_gauss = np.array([tropical_margin(rng.standard_normal((n,n))) for _ in range(500)])
    m_radem = np.array([tropical_margin(rng.choice([-1.,1.], size=(n,n))) for _ in range(500)])
    a = np.median(np.concatenate([m_gauss, m_radem]))
    b = np.std(np.concatenate([m_gauss, m_radem]))
    if b < 1e-10: b = 1.0
    ks = ks_distance((m_gauss - a)/b, (m_radem - a)/b)
    print(f"n={n:3d}: KS={ks:.4f}, b/sqrt(log n)={b/np.sqrt(np.log(n)):.3f}")
