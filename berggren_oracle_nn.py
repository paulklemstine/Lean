"""Berggren Oracle Neural Network — Bridge Theorem S2S Factoring.

Complete implementation: train, save, and benchmark.

From Catalog theorems:
- GaussianBridge.euler_two_squares_factor: N=a²+b²=c²+d² → factor via gcd(ac+bd,N)
- GaussianBridge.brahmagupta_fibonacci_Z: (a²+b²)(c²+d²) = compositions
- GaussianBridge.bridge_theorem: Gaussian integer multiplication = PPT composition
- IntegerDiffraction.diffractionAmplitude: spectral features from N mod primes
- SpectralCollapse: idempotent gates → eigenvalue projection ≈ sigmoid
- OmegaMetaOracle: contraction → convergence to fixed point
- IntegerDecoder.fourChannelSig: channel signatures for prime type detection
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
from math import gcd, isqrt, log2
from sympy import nextprime
import random, time, os

# === CATALOG FEATURE EXTRACTORS ===

PRIMES = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,
          73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151]

def spectral_features(N):
    """IntegerDiffraction: N's diffraction pattern mod primes.
    Each prime gives: (normalized_residue, QR_indicator) — eigenvalue ∈ {0,1}."""
    f = []
    for p in PRIMES:
        nm = N % p
        f.append(float(nm) / p)
        f.append(1.0 if (nm > 0 and p > 2 and pow(nm, (p-1)//2, p) == 1) 
                else (0.0 if nm == 0 else -1.0))
    return np.array(f, dtype=np.float32)

def find_s2s(N, max_a=None):
    """Find all N = a² + b² with 0 ≤ a ≤ b."""
    if max_a is None: max_a = isqrt(N)
    reps = []
    a = 0
    while a <= max_a:
        b2 = N - a * a
        if b2 < 0: break
        b = isqrt(b2)
        if b * b == b2 and b >= a:
            reps.append((a, b))
        a += 1
    return reps

def euler_factor(N, reps):
    """GaussianBridge.euler_two_squares_factor: two S2S reps → gcd factor."""
    if len(reps) < 2: return None
    (a1, b1), (a2, b2) = reps[0], reps[1]
    # Brahmagupta composition cross-terms
    for v in [a1*a2+b1*b2, a1*b2+a2*b1, abs(a1*a2-b1*b2), abs(a1*b2-a2*b1)]:
        g = gcd(abs(v), N)
        if 1 < g < N: return g
    return None

def has_s2s_rep(N, quick_check_primes=[3,7,11,19,23,31,43,47,59,67,71,79,83]):
    """Quick feasibility: all prime factors ≡ 3(mod4) must appear to even power."""
    for p in quick_check_primes:
        if N % p == 0:
            exp, tmp = 0, N
            while tmp % p == 0: tmp //= p; exp += 1
            if exp % 2 == 1: return False
    return True

# === NEURAL NETWORK ===

class BridgeOracleNN(nn.Module):
    """Spectral Oracle for S2S prediction.
    
    Architecture from Catalog:
    - IntegerDiffraction input (spectral features)
    - SpectralCollapse idempotent gate (sigmoid ≈ eigenvalue {0,1})
    - Multi-layer encoder-decoder with residual structure
    """
    def __init__(self, d_in=72, d_out=4, h=512):
        super().__init__()
        self.enc = nn.Linear(d_in, h)
        self.ln = nn.LayerNorm(h)
        self.gate = nn.Linear(h, h)  # spectral collapse gate
        self.dec = nn.Sequential(
            nn.Linear(h, 256), nn.LayerNorm(256), nn.GELU(),
            nn.Linear(256, 128), nn.GELU(),
            nn.Linear(128, d_out),
        )
    
    def forward(self, x):
        h = F.gelu(self.enc(x))
        h = self.ln(h)
        h = h * torch.sigmoid(self.gate(h))  # Catalog: SpectralCollapse
        return self.dec(h)

# === TRAINING ===

def train_bridge_oracle(n_samples=12000, epochs=400, save_path='berggren_oracle_nn.pt'):
    """Train the Bridge Oracle on semiprime S2S data."""
    random.seed(42)
    X_all, y_all = [], []
    
    print(f"Generating {n_samples} training samples...")
    for _ in range(500000):
        hb = random.randint(4, 18)
        p = 5
        while p % 4 != 1: p = nextprime(random.getrandbits(hb))
        q = 5
        while q % 4 != 1: q = nextprime(random.getrandbits(hb))
        N = p * q
        reps = find_s2s(N, max_a=isqrt(N))
        if len(reps) < 2: continue
        (a1,b1),(a2,b2) = reps[0], reps[1]
        sN = isqrt(N) if isqrt(N) > 0 else 1
        X_all.append(spectral_features(N))
        y_all.append(np.array([a1/sN, b1/sN, a2/sN, b2/sN], dtype=np.float32))
        if len(X_all) >= n_samples: break
    
    X = np.array(X_all, dtype=np.float32)
    y = np.array(y_all, dtype=np.float32)
    
    # Split
    n = len(X); nt = int(0.9 * n)
    perm = torch.randperm(n)
    Xt = torch.from_numpy(X); yt = torch.from_numpy(y)
    Xtr, Xte = Xt[perm[:nt]], Xt[perm[nt:]]
    ytr, yte = yt[perm[:nt]], yt[perm[nt:]]
    
    model = BridgeOracleNN(X.shape[1])
    opt = torch.optim.Adam(model.parameters(), lr=5e-4, weight_decay=1e-5)
    
    for ep in range(epochs):
        model.train()
        pred = model(Xtr)
        loss = F.mse_loss(pred, ytr)
        opt.zero_grad(); loss.backward(); opt.step()
        if (ep+1) % 100 == 0:
            model.eval()
            with torch.no_grad():
                vp = model(Xte)
                vl = F.mse_loss(vp, yte)
                err = torch.mean(torch.abs(vp - yte)).item()
            print(f"  Ep {ep+1}: loss={loss.item():.6f}, val={vl.item():.6f}, err={err:.5f}")
    
    torch.save(model.state_dict(), save_path)
    print(f"Model saved to {save_path}")
    return model

# === FACTORING ===

def oracle_factor(N, model, search_frac=0.15, timeout_s=3.0):
    """Factor N using Bridge Oracle + Euler's method.
    
    1. Check S2S feasibility
    2. NN predicts S2S representation locations
    3. Narrow search around predictions
    4. Two S2S reps found → Euler factor
    
    Returns factor or None."""
    t0 = time.perf_counter()
    
    if not has_s2s_rep(N): return None
    
    # NN prediction
    feat = torch.from_numpy(spectral_features(N)).unsqueeze(0)
    with torch.no_grad():
        pred = model(feat)[0].numpy()
    
    sN = isqrt(N) if isqrt(N) > 0 else 1
    centers = [max(0, int(pred[i] * sN)) for i in range(4)]  # a1, b1, a2, b2
    
    # Search around predictions
    reps = []
    for center in centers:
        lo = max(0, int(center * (1 - search_frac)))
        hi = min(sN, int(center * (1 + search_frac)))
        for v in range(lo, hi + 1):
            if time.perf_counter() - t0 > timeout_s: break
            bv = N - v*v
            if bv < 0: continue
            b = isqrt(bv)
            if b*b == bv and b >= v:
                if (v, b) not in reps:
                    reps.append((v, b))
                if len(reps) >= 2:
                    f = euler_factor(N, reps)
                    if f and N % f == 0: return f
    
    return None

# === MAIN ===

if __name__ == '__main__':
    MODEL_PATH = '/home/raver1975/lean/berggren_oracle_nn.pt'
    os.chdir('/home/raver1975/lean')
    
    # Train if needed
    if not os.path.exists(MODEL_PATH):
        print("Training new model...")
        model = train_bridge_oracle()
    else:
        model = BridgeOracleNN()
        model.load_state_dict(torch.load(MODEL_PATH))
        print("Loaded existing model")
    
    model.eval()
    
    # Benchmark
    print(f"\n{'='*70}")
    print("BERGGREN ORACLE NN — BRIDGE THEOREM FACTORING")
    print(f"{'='*70}")
    print(f"{'bits':>6} {'oracle_ms':>12} {'bf_ms':>12} {'oracle':>8} {'bf':>8} {'speedup':>8}")
    print("-" * 60)
    
    for hb in [8, 10, 12, 14, 16, 18, 20, 24, 28, 32]:
        bits = hb * 2
        random.seed(hb * 42 + 7)
        p = 5
        while p % 4 != 1: p = nextprime(random.getrandbits(hb))
        q = 5
        while q % 4 != 1: q = nextprime(random.getrandbits(hb))
        N = p * q
        sN = isqrt(N)
        
        # Oracle factor
        t0 = time.perf_counter()
        f_oracle = oracle_factor(N, model)
        oracle_t = (time.perf_counter() - t0) * 1000
        
        # Brute force
        t0 = time.perf_counter()
        reps_bf = find_s2s(N)
        f_bf = euler_factor(N, reps_bf) if len(reps_bf) >= 2 else None
        bf_t = (time.perf_counter() - t0) * 1000
        
        oracle_ok = f_oracle is not None and N % f_oracle == 0
        bf_ok = f_bf is not None and N % f_bf == 0
        speedup = bf_t / oracle_t if oracle_t > 0 and oracle_ok else 0
        
        print(f"{bits:>6} {oracle_t:>11.1f} {bf_t:>11.1f} {'✓' if oracle_ok else '✗':>8} {'✓' if bf_ok else '✗':>8} {speedup:>7.1f}x")
        
        if bf_t > 10000: break

