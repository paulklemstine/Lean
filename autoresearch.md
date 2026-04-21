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
- `/tmp/msieve/msieve` — msieve SIQS+NFS (deterministic, 64-210 bit)

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
- **ECM-first cascade** ★★★★★: gmp-ecm BEFORE rho for 64+ bit. 94→180+ bits.
- **Parallel ECM (10 procs)**: 10 simultaneous processes with spread B1 values. ~200 curves in 2.85s.
- **P-1 pre-check** ★★★★: gmp-ecm -pm1 B1=1M → 87ms, deterministic. Catches smooth p-1 cases instantly.
- **ECM -power 6** ★★★: Brent-Suyama extension. 2x improvement at 190b.
- **Skip rho for 64+ bit** ★★★★★: CRITICAL BUG FIX. pollard_rho_fast was O(p^{1/2}) = 2^45 at 170+b, hanging 4-7s.
- **Adaptive ECM deadline**: deadline = t0_ecm + min(2.85, remaining - 0.15).
- **C QS v3** ★★★: Working C Quadratic Sieve for 32-100 bit. 552ms at 81b.
- **GMP rho via ctypes**: C-level modular arithmetic. Only used for <64 bit now.
- **msieve SIQS as PRIMARY** ★★★★★: 175→203 bits (+28b). msieve deterministic for 64-210b. Restructured cascade: msieve BEFORE ECM.

### Key Architectural Insight
- **msieve SIQS is deterministic**: At 160-200 bits, msieve handles factoring in 134ms-1.8s with 100% success.
- **ECM variance is overcome by msieve**: For 64-210b, msieve makes factoring deterministic. ECM still needed for 210+b.
- **Cascade priority**: trial div → perfect power → Fermat → rho(<64b) → P-1 → msieve(64-210b) → msieve//ECM parallel(210+b)

### Dead Ends
- **Williams p+1 in cascade**: WORSE for balanced semiprimes
- **B1=25M ECM**: WORSE (too slow per curve)
- **Explicit -sigma values**: WORSE (default random state is better)
- **Torsion groups (-torsion)**: ECM 7.0.5 doesn't support ANY torsion groups
- **IOF/Catalog algorithms for 170+ b**: All O(√N). Infeasible classically.
- **Integer diffraction/four channel**: Requires divisors → circular for factoring
- **Python SIQS for 120+ bit**: 10-20s. Too slow.
- **ECM before msieve for 64-210b**: WORSE. msieve is deterministic and faster.

### Scaling Data (current best)
| Bits | Time | Best method |
|------|------|-------------|
| 24 | 0.009ms | CRT |
| 32 | 3ms | C QS |
| 48 | 1.3ms | rho |
| 64 | 9ms | GMP rho |
| 80 | 15ms | msieve SIQS |
| 100 | 64ms | msieve SIQS |
| 120 | 500ms | msieve SIQS |
| 140 | 500ms | msieve SIQS |
| 160 | 134ms | msieve SIQS |
| 180 | 590ms | msieve SIQS |
| 190 | 866ms | msieve SIQS |
| 200 | 1.8s | msieve SIQS |
| 203 | ~2.8s | msieve SIQS (deterministic) |
| 210+ | depends | ECM+msieve parallel |

### Next Steps
- **Push msieve to 220+ bit**: With better timeout management and larger -mb flag
- **GPU-ECM**: 1000+ parallel curves would push 210+b
- **NFS (Number Field Sieve)**: msieve has NFS built in; need to test for 210+b