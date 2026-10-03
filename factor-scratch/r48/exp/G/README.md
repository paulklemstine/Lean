# G — code for the adversarial audit of E-7

Run order:
  python3 G_selftest_e7.py    # self-tests FIRST (25 known class numbers -3..-163,
                              # is_smooth vs sympy.factorint at 2 bounds, Hasse on 200 curves)
  python3 G_e7_audit.py 29 60 900      # Run A: matched 29-bit order scale, n=60/arm
  python3 G_parity_control.py 29      # Run B: adds uniform + odd-uniform control arms

Results: G_e7_results_v1.json, G_parity_L29.log
CI + E-6b consistency: python3 G_ci_and_e6b.py

## KNOWN-BAD, DO NOT USE
`G_dickman_WIP_broken.py` — my numerical Dickman rho(u) integration is WRONG
(it returns rho(2)=0.5, correct value 0.3069; the backward-Euler discretisation of
u*rho'(u) = -rho(u-1) collapses). Left in place deliberately rather than deleted,
because the notes must not cite it. No conclusion in G_adversary.md rests on it:
every Dickman statement was replaced by DIRECT MEASUREMENT on 3000-4000 sampled
integers per scale (see G_ci_and_e6b.py output).
