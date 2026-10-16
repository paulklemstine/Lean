# HYPOTHESIS_TREE.md — Research Branch Hierarchy

Status legend: [ACTIVE] [EXPLORED] [FALSIFIED] [QUEUED] [VALIDATED]

## Vector C — Endomorphism / distinguished points / GLV (ACTIVE, validated)
- [VALIDATED] H-001 GLV negation-and-phi quotient Pollard Rho on j=0 curves.
    \* **Claim:** Walking on equivalence classes { ±P, ±φ(P), ±φ²(P) } (size≤6) reduces
      group ops by factor √6 (from 1.253√n to 1.253√n/√6 ≈ 0.512√n).
    \* **Evidence:** 4 tiers × 20-40 instances. Mean/sqrt(n): 0.47, 0.50, 0.56, 0.57 (≈0.51).
    \* **Child branches:**
      - [QUEUED] H-002 Kangaroo (2-collision) on same quotient; expected same √6
        factor but cleaner constant factor on known interval.
      - [QUEUED] H-003 Full 12-transform including twist maps on all three
        j-invariants (not just j=0).
      - [FALSIFIED] H-004 Adaptive canonical representative at each step
        (normalisation without extra inversion; batching of inversions).
        Evidence V-005: Jacobian mixed-add + affine conversion per step gives
        byte-identical group-op counts and 100% recovery, but slower wall-clock
        (0.82-0.95x at 20/24/28/36-bit; 40 inst @20b, 10 @24b, 5 @28b & 36b).
        No >5% speedup -> H-004 falsified.

## Vector C — simple negation map (EXPLORED)
- [VALIDATED] H-005 Negation map (-P same x) reduces ops by ~√2 (0.7–0.9√n).
    \* Child: [QUEUED] Hyperelliptic curve (negation map) extension.

## Vector A — ECDSA HNP / Lattice (ACTIVE, theory-derived)
- [ACTIVE] H-006 Minimum leakage for HNP recovery.
    \* Construction: beta_i = s_i^{-1} r_i mod n; t_i = (k_hi_i - s_i^{-1} z_i) mod n;
      solve CVP (or embedded LLL) for d (d recovered from v closest to t).
    \* Theory: recoverable when unknown nonce bits ell ≪ log n AND >=2 sigs enough
      for ell ≤ bits/4 with m ≥ (bits)/(bits-ell).
    \* Status: construction is correct (verified derivation), but empirical recovery
      requires proper lattice scaling/HNF of the ill-conditioned basis-bet.
      - Sub-branch resolved: scaled lattice (see V-006) recovers d at m>=2, 16/20-bit.
      - Scaling validated (V-006b, 2026-10-16): LLL-only recovery on 24/28/32-bit
        targets (n bit-length 22/28/31), 420 attempts, 400 recoveries verified by
        d*G==Q. m=2 sufficient at leak=0.25 (12/12, 10/10, 8/8); m>=3 sufficient
        at leak=0.5; m=2 only partially at leak=0.5 (1/12, 6/10, 3/8) —
        information-theoretic boundary, BKZ-12 recovers none. Cost 0.07 ms (m=2) to
        0.8 ms (m=16); no BKZ needed. Trial log: /tmp/opencode/hnp_trials.jsonl.
      - The unscaled construction is superseded; use ec_research/hnp_lattice.py.
    \* Child: [VALIDATED] H-007 correctly scaled HNP with column/row weighting and
      per-dimension BKZ (2.0) — needed to reproduce the theoretical threshold.
      Scaling evidence: V-006b (24-32 bits).

## Vector B — Summation polynomials / index calc
- [QUEUED] H-008 Factor base via small-degree EC points + Semaev S_m degree bound test
  on prime fields.

## Vector D — p-adic / anomalous
- [EXPLORED] H-009 Smart's linear attack on anomalous curves (control: huge speedup).
    \* **Claim:** On anomalous curves E/F_p (#E=p, trace 1), Hensel-lift + p-multiply +
      formal-log normalisation recovers d in polynomial time vs BSGS O(sqrt p).
    \* **Evidence:** `ec_research/smart.py`. Validated recovery (d_rec==d, verified
      against Q) on random non-CM anomalous curves: 12-bit (3/3), 16-bit (2/2),
      20-bit (1/1). Smart wall time ~1-2 ms; BSGS comparable at these sizes but
      scaling differs (Smart polynomial, BSGS exponential).
    \* **Blocker:** j=0 CM trace-1 curves have v_p(t(p*lift(P)))=2, so naive phi==0
      mod p; canonical lifting required. Logged as G-009.
    \* **Child:** [QUEUED] H-010 canonical lifts / higher p-adic lifts for non-anomalous
      N≈p.
- [QUEUED] H-010 Higher p-adic lifts with CRT for non-anomalous N≈p.

## Vector E — division polynomials
- [QUEUED] H-011 Balanced ternary meet-in-the-middle via division polynomial trees.
