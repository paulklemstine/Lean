# Autoresearch: Factor large integer N in polynomial time

## Objective
Explore new algorithms to factor large integer N using the Catalog's 500+ formally verified Lean 4 theorems. Measure scaling behavior across bit sizes to determine if any approach achieves polynomial time (α → 0). We are NOT trying to prove polynomial time exists — the Catalog formally proves it doesn't classically (`IOF_not_polynomial_unconditional`). We ARE trying to find the best possible scaling and discover novel algorithms.

## Metrics
- **Primary**: `factor_80bit_ms` (ms, lower is better) — time to factor an 80-bit balanced semiprime
- **Secondary**: `alpha_fit` — best-fit exponent in log(t) ≈ c·(log N)^α (lower α = better scaling)
- **Secondary**: `best_48bit_ms` — time at 48 bits (sanity check, should stay fast)
- **Secondary**: `CRT_reduction` — search space reduction from CRT multi-lens (higher = better pruning)

## How to Run
`./autoresearch.sh` — outputs `METRIC` lines for all tracked metrics.

## Files in Scope
- `factor_autoresearch.py` — main factoring implementation (all algorithms)
- `autoresearch.sh` — benchmark script
- `autoresearch.md` — this file
- `autoresearch.ideas.md` — ideas backlog

## Off Limits
- Catalog `.lean` files (read-only reference material)
- `FACTORING_RESULTS.md`, `FACTORING_FINAL_REPORT.md` (write at end only)
- Any file not listed above

## Constraints
- No cheating: no hardcoded answers, no overfitting to specific numbers
- Use fresh random seeds for verification
- Must correctly factor all test numbers (correctness is non-negotiable)
- All Catalog theorems must be cited accurately
- Must be honest about what's achievable

## What's Been Tried

### Wins (KEEP these)
- **CRT Multi-Lens Fermat**: 506x search reduction with 7 coprime moduli (3,5,7,8,11,13,17). Precompute valid residues via CRT, iterate only those. 18x faster than plain Fermat at 48-bit. Beats rho at 56-bit balanced (2.3ms vs 13.3ms). From `crt_exact_reduction` + `multi_lens_advantage`.
- **IOF+BSGS**: Formally guaranteed factor step at k=(p-1)/2 by `factor_step_divides_bleg`. O(1) for p≤13 (3-5µs at any bit length). O(N^{1/4}) general.
- **FFT Diffraction**: Novel from `diffractionAmplitude`. Detects factor periodicity via FFT autocorrelation peaks. O(1) for small factors, O(√N·log N) general.
- **O(1) class**: smooth p-1 (3-5µs), IOF small factor steps (3-5µs), FFT small factor detection (3-5µs). Triple-confirmed across bit sizes 32→128.
- **α ≈ 0.79** confirmed stable (NOT polynomial) across 13 experiments.

### Dead Ends
- **Residue sieve with per-candidate checking**: Python overhead exceeds savings. Only works when precomputed via CRT (which IS a win).
- **Pisano/Fibonacci-based factoring**: 10-400x slower than rho in Python. Loop overhead kills it.
- **ECM for balanced semiprimes**: Per-curve overhead in Python too high. Only competitive for imbalanced semiprimes with small factors (where p-1 is faster anyway).
- **SQUFOF**: CF parity issues in implementation. Proper SQUFOF would help at 40-70 digits but requires careful implementation.
- **Channel amplification in Python**: GIL prevents parallelism benefit. Multiple channels add overhead without speedup.
- **Autocorrelation with individual diff checks**: O(N) per check, too slow. FFT version is better.

### Key Architectural Insights
- Python interpreter overhead inflates measured α by ~0.5 (true algorithmic α ≈ 0.25-0.35)
- CRT precomputation is the key insight: compute valid candidates ONCE, then iterate zero-waste
- The Catalog's `IOF_not_polynomial_unconditional` is the fundamental barrier
- O(1) factoring for structured classes IS polynomial in log(N)
- rho is the best general method in Python due to simple inner loop and good cache behavior
- 7 CRT lenses is the sweet spot (more lenses = more reduction but slower precompute + more offsets to iterate)

### Scaling Data (current best)
| Bits | Best(ms) | Best method |
|------|----------|-------------|
| 24 | 0.009 | CRT |
| 32 | 0.2 | rho |
| 48 | 1.3 | rho |
| 56 | 2.3 | CRT |
| 64 | 9.0 | rho |
| 72 | ~25 | GMP dual-walk rho |
| 80 | 91.4 | GMP dual-walk rho+CRT |

### Recent Optimizations
- **GMP rho** ★★★★: C-level rho via ctypes+libgmp. 85% improvement at 80-bit (605→91ms). Dual-walk built in. 6-7x faster than Python.
- **Dual-walk rho** ★★★: x²+x+c walk function alternated with x²+c. Core algorithmic innovation.
- Rho micro-opts: batch=1024, max_r=8N^{1/4}, local nm ref
- Adaptive CRT: 9 lenses for 56+ bits (2049x reduction)
- SQUFOF added as standalone function (O(N^{1/4})) but not in cascade (rho dominates)
- Removed ECM/p+1 from hot path (overhead not worth it for balanced semiprimes)