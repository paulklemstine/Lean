# R48-A: PREREGISTERED HYPOTHESES  (written before any measurement)

Date: 2026-10-03. Author: r48 class-group agent.
Rule honoured: hypotheses stated BEFORE the runs that test them. Numbers below are
predictions with a stated gate, not post-hoc descriptions.

## H0 (the twin control). The 0.720-vs-0.440 advantage.
CLAIM UNDER TEST (from E6b/E6c/E7): at matched scale, P(|Cl(Q(sqrt(D)))| is
B-smooth) > P(EC group order m is B-smooth) in a matched B band.

H0-PREDICTION: the advantage is *at least partly* real but is NOT 0.72 vs 0.44
at true matched scale. Specifically, at a matched bit length k and matched
B, I predict the class-number advantage over a UNIFORM-RANDOM integer
baseline is large (class numbers are pushed to be odd, and h(D) ~ sqrt(D)/pi
*L(1,chi) is concentrated), but the advantage over the correct EC baseline
(Hasse-constrained m = p+1-t, |t| <= 2 sqrt(p)) SHRINKS below 10 percentage
points, because both are then dominated by the same Dickman function.
GATE: if the class-vs-Hasse-EC gap is < 10 pp at every matched (k,B) cell with
n >= 200 per cell, the *lottery* advantage is REFUTED as a source of speedup.

H0-SELF-TEST (mandatory): the control harness must be fed a synthetic
generator that returns 100% smooth and one that returns 0% smooth, and must
report 1.000 and 0.000 for them. A harness that cannot detect these is broken.

## H1 (the structural claim — THE DECISIVE ONE). Can p even enter?
The design (E6D) requires p to constrain the walk. p enters the form
arithmetic ONLY through the discriminant D modulo p. Dichotomy:

  (a) p does NOT divide D. Then O_D/p is a field (inert) or F_p x F_p
      (split). Both have TRIVIAL ideal class group. => Cl(O_D/p) = {1},
      the walk carries ZERO information mod p, and gcd(a_k, N) > 1 happens
      only by coincidence at rate ~L/p.
  (b) p DOES divide D (i.e. D is a multiple of N). Then O_D/p is the
      degenerate ring F_p[e]/e^2, and the forms of discriminant 0 mod p under
      composition form a group isomorphic to (F_p, +), of order exactly p.
      Every non-identity element has order exactly p. => NO smoothness
      lottery: the order is p, not a random divisor of a random number.
      Walk cost is the birthday bound sqrt(p) = N^{1/4}.

H1-PREDICTION (numeric, decided in advance):
  * Cl of forms of discriminant D == 0 (mod p) has order exactly p, and is
    cyclic of order p. Measured on >= 20 primes p in [10^6, 10^9], the
    composition table of the residue classes mod p will have every non-identity
    element of order exactly p (0 exceptions out of >= 20*3 sampled elements).
  * Consequently the class-group walk cannot do better than
    N^{1/4} = Pollard-rho cost, i.e. it CANNOT be L[1/2], and the smoothness
    advantage measured in E6b/E6c/E7 is IRRELEVANT to it.

GATE: if H1 holds (0 exceptions), the axis is REFUTED as an L[1/2] mechanism,
and the refutation is structural, not statistical. This is a SUCCESSFUL
negative result for the program.

## H2 (the walk). Does the prototype find factors?
H2-PREDICTION: a SQUOF-style class-group walk on N with D = -k*N will find
factors at the N^{1/4} rate (Pollard-rho-like), NOT faster. Concretely, on
20 semiprimes with 20-bit factors (N ~ 2^40), expected median work
~ sqrt(2^20) ~ 10^3 form steps; if the walk instead finds factors in O(10)
steps consistently, something is wrong with my cost model (or it is magic).
GATE: median steps per factor within [0.2, 5] x 10^3. Outside => investigate.

## Pre-registered honesty rules for this round
- Any quantity computed using knowledge of p is labelled [uses p]. The
  factored-output timing path may NEVER use p.
- All rates carry a sample size and a Wilson 95% interval.
- Every rate gets a control run AT THE PARAMETER IT WAS DERIVED AT.
