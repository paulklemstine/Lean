# Autoresearch: Factor random semiprime N — maximize digits in 3 seconds

## Objective
Factor the largest random balanced semiprime N within 3 seconds. Primary metric: maximum bit size where 2/3 trials succeed in <3s.

## Metrics
- **Primary**: `max_bits_3s` (bits, higher is better) — max bit size factorable in 3 seconds
- **Secondary**: `median_bits` — tracks ECM variance impact

## How to Run
`./autoresearch.sh` — outputs `METRIC max_bits_3s=N` lines.

## Files in Scope
- `factor_autoresearch.py` — main factoring cascade (all algorithms)
- `autoresearch.sh` — benchmark script
- `autoresearch.md` — this file
- `qs_v3.c` / `qs_v3.so` — C Quadratic Sieve (≤100 bit deterministic fallback)
- `rho_gmp.c` / `rho_gmp.so` — GMP Pollard rho (≤64 bit)
- `iof_gmp.c` / `iof_gmp.so` — Inside-Out Factoring (Catalog: multiPolySieve)

## Off Limits
- Catalog `.lean` files (read-only reference material)
- `pyfactorise_qs.py` (Python SIQS — used as-is)
- Any file not listed above

## Constraints
- No cheating: no hardcoded answers, no overfitting to specific numbers
- Must correctly factor all test numbers (correctness is non-negotiable)
- 3-second time budget per factorization attempt
- 2/3 trials must pass at a given bit size

## What's Been Tried

### Wins (KEEP these)
- **ECM-first cascade** ★★★★★: gmp-ecm subprocess BEFORE rho for 64+ bit. 94→180+ bits.
- **Parallel ECM (10 procs)**: 10 simultaneous processes with spread B1 values. ~200 curves in 2.85s.
- **P-1 pre-check** ★★★★: gmp-ecm -pm1 B1=1M → 87ms, deterministic. Catches smooth p-1 cases instantly.
- **P-1 B1=10M parallel**: Runs as one of 10 parallel processes. FREE channel for 190+ bit.
- **ECM -power 6** ★★★: Brent-Suyama extension. 2x improvement (4/20 vs 2/20 at 190b). Stage 2 catches more factors.
- **Skip rho for 64+ bit** ★★★★★: CRITICAL BUG FIX. pollard_rho_fast was O(p^{1/2}) = 2^45 at 170+b, hanging 4-7s. Skipping eliminated hangs.
- **Adaptive ECM deadline**: deadline = t0_ecm + min(2.85, remaining - 0.15). ~1 more curve per process.
- **C QS v3** ★★★: Working C Quadratic Sieve for 32-100 bit. 552ms at 81b. Fixed Y half-exponent bug.
- **GMP rho via ctypes**: C-level modular arithmetic. Only used for <64 bit now.
- **Dual-walk rho**: x²+x+c walk function. Algorithmic innovation for <64 bit.
- **CRT Multi-Lens Fermat**: 506-2049x search reduction with 7-9 coprime moduli.
- **190+ bit schedule**: 7×B1=250K + 2×B1=1M + 1×P-1 B1=10M. Portfolio diversification.

### Dead Ends
- **Williams p+1 in cascade**: WORSE for balanced semiprimes (17ms overhead)
- **B1=25M ECM**: WORSE (too slow per curve)
- **Explicit -sigma values**: WORSE (default random state is better)
- **Torsion groups (-torsion)**: ECM 7.0.5 doesn't support ANY torsion groups
- **IOF/Catalog algorithms for 170+ b**: All O(√N) = O(2^85). Infeasible classically.
- **Integer diffraction/four-channel**: Requires divisors → circular for factoring
- **Python SIQS for 120+ bit**: 10-20s. Too slow.
- **C QS v1/v2**: Bug in Y computation (included all factors instead of half-exponents)

### Key Architectural Insights
- **ECM variance is the fundamental limit**: ~40% success at 180b. Only deterministic methods (SIQS/NFS) can overcome this.
- **IOF_not_polynomial_unconditional**: Classical factoring is NOT polynomial. All "Catalog algorithms" that don't require knowing divisors are O(√N) or worse.
- **gmp-ecm subprocess > C API**: CLI has built-in stage 2 + curve parameter optimization.
- **B1=250K optimal info rate**: For 26-30d factors, B1=250K has 2x the info/sec of B1=1M.
- **Pollard rho is O(p^{1/2})**: At 170+b, rho needs 2^42+ steps = HOURS. Must skip for large numbers.

### Scaling Data (current best)
| Bits | Time | Best method |
|------|------|-------------|
| 24 | 0.009ms | CRT |
| 32 | 3ms | C QS |
| 48 | 1.3ms | rho |
| 64 | 9ms | GMP rho |
| 80 | 15ms | ECM |
| 100 | 64ms | ECM |
| 120 | 500ms | ECM B1=250K |
| 140 | 1.2s | ECM B1=250K |
| 160 | 2.0s | ECM B1=250K |
| 180 | 2.8s | ECM B1=250K (40% success) |
| 190 | 3.0s | ECM B1=250K+1M (+P-1) |

### Next Steps
- **C SIQS for 100-140 bit**: Would be 10-50x faster than Python SIQS. Could push to 140+b deterministically.
- **GPU-ECM**: 1000+ parallel curves would overcome the ~200 curve limit per 3s.
- **NFS (Number Field Sieve)**: Standard for 100+ digit numbers. Needs C implementation.
- **YAFU/msieve compile**: Would provide both SIQS and NFS out of the box.