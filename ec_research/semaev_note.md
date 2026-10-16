# Semaev S3 feasibility note (H-008, Vector B)

**Curve:** p=65521, a=0, b=17, #E=n=65353 (prime). G=(1,1086) (any nonzero point generating
the ECDLP subgroup since n is prime). An ECDLP instance Q=d*G is generated internally (d secret).

**Factor base (exact definition):** FB = { P in E(F_p)\{O} : x(P) in [0,256) }.
Equivalently `is_fb_point(P)` iff `0 <= P.x < THRESH (THRESH=256)`. Both y-signs for a square
residue x count as separate points. No subfield exists for prime p; this is the explicit
low-interval normalisation.

**Measurements (from `ec_research/semaev_results.json`):**
- V_FB = 252 points; V_FB / n = 0.003856 (~0.4%).
- Relation trials (random P,Q): R=-(P+Q) in FB for 28 / 10000 = 0.0028
  (expected ~THRESH/p = 0.00391).
- S3 (Big polynomial) root experiment over 5000 random (x1,x2), x1 != x2:
  degree always <= 2 in x3; 0 roots for 2524 pairs, 2 roots for 2476 pairs,
  1 root for 0 pairs; 4952 roots total (avg 0.9904 per trial).
- FB roots among roots: 17 / 4952 = 0.00343; pairs with >=1 FB root: 17 / 5000 = 0.00340.

**Verdict:** Feasibility/threshold only. Semaev's S3 is symbolically computable and degree-bounded
(no degree explosion) at 16-bit, and the factor-base density/root set is directly measurable.
However the simple contiguous low-x factor base has only ~0.4% density, yielding ~0.3% relation
and hit rates. No group-operation-count reduction or speedup is demonstrated versus generic
ECDLP. H-008 remains EXPLORED, not VALIDATED for speedup. No speedup claim.
"""