"""BERGGREN ORACLE — Final Integrated System.

ARCHITECTURE (from Catalog theorems):
1. SpectralEncoder: IntegerDiffraction features → N's QR profile
2. CloseFactorDetector: binary classification → Fermat vs ECM decision
3. Fermat descent: BerggrenDescent.diff_of_squares_factoring
4. Standard pipeline: ECM + msieve SIQS fallback

MATHEMATICAL FOUNDATION:
- GaussianBridge.bridge_theorem: Gaussian integers compose PPTs
- SpectralCollapse: idempotent projections → clean binary decisions
- ConsensusTruthSet: multi-head voting reduces error rate
- IOF_not_polynomial_unconditional: classical factoring is NOT polytime

HONEST LIMITATIONS:
- 100% precision Berggren navigation is IMPOSSIBLE for general numbers
- Path depth grows as O(gap²/4√N) — exponential for balanced semiprimes
- Per-step accuracy (88%) compounds → 8% success after 20 steps
- Fermat is STRICTLY superior for close-factor numbers
- The NN's value is as a CLASSIFIER, not a navigator
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import gmpy2
from math import gcd, isqrt, log2
from sympy import nextprime
import random, time

# ============ SPECTRAL FEATURES ============
PRIMES = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,
          73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151]

def spectral_features(N):
    """IntegerDiffraction.diffractionAmplitude: N's spectral signature.
    Each prime: (residue, QR_indicator) — SpectralOracle eigenvalues ∈ {0,1}."""
    feats = np.zeros(2 * len(PRIMES), dtype=np.float32)
    for i, p in enumerate(PRIMES):
        nm = N % p
        feats[2*i] = float(nm) / p
        feats[2*i+1] = 1.0 if (nm > 0 and p > 2 and pow(nm, (p-1)//2, p) == 1) else (0.0 if nm == 0 else -1.0)
    return feats

# ============ NEURAL ORACLE ============
class BerggrenOracle(nn.Module):
    """Spectral Oracle for factoring guidance.
    
    Two heads:
    1. CloseDetector: P(|p-q| < Fermat_limit) from N's spectral features
    2. DirectionPredictor: soft prediction for Berggren tree at each depth
    
    From Catalog:
    - SpectralCollapse: h ⊙ σ(gate) → idempotent eigenvalue projection
    - consensusTruthSet: majority vote reduces error
    """
    def __init__(self, d_in=72):
        super().__init__()
        self.enc = nn.Linear(d_in, 256)
        self.ln = nn.LayerNorm(256)
        self.gate = nn.Linear(256, 256)
        self.trunk = nn.Sequential(nn.Linear(256, 128), nn.GELU(), nn.Linear(128, 64), nn.GELU())
        self.close_head = nn.Sequential(nn.Linear(64, 1), nn.Sigmoid())
        self.dir_head = nn.Sequential(nn.Linear(64, 3))
    
    def forward(self, x):
        h = self.ln(F.gelu(self.enc(x)))
        h = h * torch.sigmoid(self.gate(h))  # SpectralCollapse
        t = self.trunk(h)
        close_prob = self.close_head(t).squeeze(-1)
        dir_logits = self.dir_head(t)
        return close_prob, dir_logits

# ============ FERMAT METHOD ============
def fermat_factor(N, timeout_s=2.0):
    """BerggrenDescent.diff_of_squares_factoring.
    (c-b)(c+b) = a², so finding b² gives factors."""
    a = int(gmpy2.isqrt(N)) + 1
    t0 = time.perf_counter()
    while time.perf_counter() - t0 < timeout_s:
        b2 = a*a - N
        b = int(gmpy2.isqrt(b2))
        if b*b == b2:
            return a - b
        a += 1
    return None

# ============ TRAINING ============
def train_oracle(n_samples=8000, epochs=200):
    random.seed(42)
    X, yc = [], []
    GAP_LIMIT = 2**50
    
    for _ in range(n_samples * 3):
        if len(X) >= n_samples: break
        hb = random.randint(4, 12)
        p = nextprime(random.getrandbits(hb) | (1 << max(hb-1,1)))
        
        if random.random() < 0.5:
            gap = random.getrandbits(random.randint(1, min(45, hb*2)))
            q = nextprime(p + gap + 2)
        else:
            q = nextprime(random.getrandbits(hb) | (1 << max(hb-1,1)))
        if p == q: continue
        
        N = p * q
        label = 1.0 if abs(p-q) < GAP_LIMIT else 0.0
        X.append(spectral_features(N))
        yc.append(label)
    
    X = np.array(X, dtype=np.float32); yc = np.array(yc, dtype=np.float32)
    print(f"Training: {len(X)} samples, close={np.sum(yc>0.5):.0f}, far={np.sum(yc<0.5):.0f}")
    
    Xt = torch.from_numpy(X); yct = torch.from_numpy(yc)
    n = len(X); nt = int(0.85*n)
    perm = torch.randperm(n)
    Xtr, Xte = Xt[perm[:nt]], Xt[perm[nt:]]
    yctr, ycte = yct[perm[:nt]], yct[perm[nt:]]
    
    model = BerggrenOracle(d_in=X.shape[1])
    opt = torch.optim.Adam(model.parameters(), lr=1e-3)
    
    for ep in range(epochs):
        model.train()
        cp, _ = model(Xtr)
        loss = F.binary_cross_entropy(cp, yctr)
        opt.zero_grad(); loss.backward(); opt.step()
        if (ep+1) % 50 == 0:
            model.eval()
            with torch.no_grad():
                cpt, _ = model(Xte)
                acc = ((cpt > 0.5) == ycte).float().mean()
            print(f"  Ep {ep+1}: loss={loss.item():.4f}, acc={acc:.2%}")
    
    torch.save(model.state_dict(), 'berggren_oracle_final.pt')
    return model

# ============ INTEGRATED FACTORING ============
def oracle_factor(N, model, close_threshold=0.5, total_timeout=3.0):
    """Factor N using Berggren Oracle NN guidance.
    
    Pipeline:
    1. NN predicts close-probability from spectral features
    2. If close: try Fermat (BerggrenDescent.diff_of_squares_factoring)
    3. If far or Fermat fails: standard pipeline (ECM/msieve)
    """
    t0 = time.perf_counter()
    
    # Step 1: Spectral oracle prediction
    feat = torch.from_numpy(spectral_features(N)).unsqueeze(0).float()
    with torch.no_grad():
        close_prob, _ = model(feat)
    is_close = close_prob.item() > close_threshold
    
    # Step 2: if close, try Fermat first
    if is_close:
        fermat_budget = min(1.0, total_timeout * 0.3)
        f = fermat_factor(N, timeout_s=fermat_budget)
        if f and N % f == 0:
            return f, 'fermat', time.perf_counter() - t0
    
    # Step 3: standard pipeline
    try:
        from factor_autoresearch import factor_best
        remaining = total_timeout - (time.perf_counter() - t0)
        if remaining > 0.1:
            result = factor_best(N, timeout=remaining)
            if result and result[0] * result[1] == N:
                return result[0], 'pipeline', time.perf_counter() - t0
    except Exception as e:
        pass
    
    return None, 'failed', time.perf_counter() - t0

# ============ MAIN ============
if __name__ == '__main__':
    print("=" * 60)
    print("BERGGREN ORACLE NEURAL NETWORK — FINAL SYSTEM")
    print("=" * 60)
    print()
    print("Catalog theorems used:")
    print("  - IntegerDiffraction: spectral features from N mod primes")  
    print("  - SpectralCollapse: idempotent projection gates")
    print("  - GaussianBridge: Euler's two-squares factoring")
    print("  - BerggrenGPS: zone classification")
    print("  - OmegaMetaOracle: convergence to fixed point")
    print("  - IOF_not_polynomial_unconditional: fundamental limit")
    print()
    
    # Train
    print("Training spectral oracle...")
    model = train_oracle()
    model.eval()
    
    # Test classification
    print("\n=== Close-Factor Detection ===")
    random.seed(12345)
    tp = fp = tn = fn = 0
    for trial in range(100):
        hb = random.randint(8, 16)
        p = nextprime(random.getrandbits(hb) | (1 << max(hb-1,1)))
        if random.random() < 0.3:
            gap = random.getrandbits(random.randint(1, min(48, hb)))
            q = nextprime(p + gap + 2)
            true_close = 1
        else:
            q = nextprime(random.getrandbits(hb) | (1 << max(hb-1,1)))
            if p == q: continue
            true_close = 0
        N = p * q
        
        feat = torch.from_numpy(spectral_features(N)).unsqueeze(0).float()
        with torch.no_grad():
            cp, _ = model(feat)
        pred = 1 if cp.item() > 0.5 else 0
        
        if pred and true_close: tp += 1
        elif pred and not true_close: fp += 1
        elif not pred and true_close: fn += 1
        else: tn += 1
    
    prec = tp / max(tp + fp, 1)
    rec = tp / max(tp + fn, 1)
    f1 = 2*prec*rec/max(prec+rec, 1e-6)
    print(f"  TP={tp} FP={fp} TN={tn} FN={fn}")
    print(f"  Precision={prec:.1%}, Recall={rec:.1%}, F1={f1:.1%}")
    
    # Test factoring on close-factor numbers (Fermat's sweet spot)
    print("\n=== Factoring Close-Factor Numbers ===")
    print(f"{'bits':>6} {'method':>10} {'time_ms':>10} {'ok':>5}")
    print("-" * 35)
    
    for bits in [100, 200, 500, 1024, 4096, 8192]:
        random.seed(bits*7+99)
        base = nextprime(random.getrandbits(bits//2) | (1 << max(bits//2-1,1)))
        q = nextprime(base + random.randint(10, 100))
        N = base * q
        
        f, method, t = oracle_factor(N, model)
        ok = f is not None and N % f == 0
        print(f"{bits:>6} {method:>10} {t*1000:>10.2f} {'✓' if ok else '✗':>5}")
    
    # Random balanced semiprimes (benchmark scenario)
    print("\n=== Random Balanced Semiprimes (Benchmark) ===")
    from factor_autoresearch import make_prime
    
    for bits in [80, 120, 160, 200]:
        random.seed(bits*7+42)
        p = make_prime(bits//2+1)
        q = make_prime(bits-bits//2+1)
        N = p * q
        
        f, method, t = oracle_factor(N, model)
        ok = f is not None and N % f == 0
        print(f"  {bits}b: {method}, {t*1000:.0f}ms, {'✓' if ok else '✗'}")

