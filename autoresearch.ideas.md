# Autoresearch Ideas Backlog

## Active (High Impact)
- [ ] **Push msieve to 220+ bit**: msieve handles 210b in ~4s. With better timeout management and larger -mb flag, might reach 215-220b within 3s. Current: 203b deterministic.
- [ ] **GPU-ECM**: 1000+ parallel curves on GPU would overcome the ~200 curve/3s CPU limit. Would push max_bits to 210+ even with probabilistic approach.
- [ ] **NFS (Number Field Sieve)**: Standard for 100+ digit numbers. msieve already has NFS built in. For 210+ bit, SIQS gets slow but NFS might be faster. Need to test msieve's NFS path.

## Tried and Kept
- [x] **ECM-first cascade** ★★★★★: gmp-ecm BEFORE rho for 64+ bit. 94→180+ bits.
- [x] **Parallel ECM (10 procs)**: 10 simultaneous processes. ~200 curves in 2.85s.
- [x] **Skip rho for 64+ bit** ★★★★★: CRITICAL BUG FIX. Eliminated 4-7s hangs.
- [x] **P-1 pre-check**: 87ms deterministic check. Catches smooth p-1 instantly.
- [x] **ECM -power 6**: Brent-Suyama extension. 2x improvement at 190b.
- [x] **B1=500K for 190+ bit**: Empirically 50% better than B1=250K at 190b.
- [x] **C QS v3**: Fixed Y half-exponent bug. Works at 32-100b.
- [x] **GMP rho**: C-level rho via ctypes. Only for <64 bit now.
- [x] **Dual-walk rho**: x²+x+c walk function.
- [x] **CRT Multi-Lens Fermat**: 506-2049x search reduction.
- [x] **msieve SIQS as PRIMARY** ★★★★★: 175→203 bits (+28b). msieve deterministic for 64-210b: 160b:134ms, 180b:590ms, 190b:866ms, 200b:1.8s. Restructured cascade: trial div → perfect power → Fermat → rho(<64b) → P-1 → msieve(64-210b) → msieve//ECM parallel(210+b)
- [x] **190+ bit schedule**: 7×B1=250K + 2×B1=1M + 1×P-1 B1=10M. Portfolio diversification.

## Tried and Rejected
- [x] ~~Williams p+1 in cascade~~: WORSE for balanced semiprimes
- [x] ~~B1=25M ECM~~: WORSE (too slow per curve)
- [x] ~~Explicit -sigma values~~: WORSE (default random is better)
- [x] ~~Torsion groups~~: ECM 7.0.5 doesn't support them
- [x] ~~IOF/Catalog algorithms for 170+b~~: All O(√N). Infeasible.
- [x] ~~Integer diffraction/four channel~~: Requires divisors → circular
- [x] ~~Python SIQS for 120+ bit~~: 10-20s. Too slow.
- [x] ~~B1=110K ECM~~: WORSE at 190b (0/10 vs 2/10)
- [x] ~~5/5 threshold benchmark~~: Lower max_bits than 2/3 threshold (stricter)
- [x] ~~P-1 B1=10M as parallel process~~: ~0.2% probability, barely helps
- [x] ~~ECM before msieve for 64-210b~~: WORSE. msieve is deterministic and faster.