# E-8: Form-Composition Walk Demo — IN PROGRESS
Algorithm (per E6D_IDEA_ECM.md): D=-q fixed; random form f=[a,b,c] reduced;
iterate f <- f*f (NUDUPL squaring) then compose with a fixed base form, all
coefficients reduced mod N; after k steps gcd(a or c ± const, N) extracts p
when the hidden order's period divides the walk length. Pitfalls: ambiguous
forms need b-parity normalization; period unknown -> birthday-style restarts.
STATUS: design locked; implementation deferred one cycle (composition
arithmetic needs careful exact tests — see regex-incident lesson).

## Run results (first cycle)
- **Composition correctness: VERIFIED** (identity f·f⁻¹ = principal form PASS
  via cypari2 qfbcompraw/Qfb).
- Walk of 200 compositions with tiny fixed D=-107: no factor. DIAGNOSED: with
  |D| ~ 10², Cl(D) has microscopic order — the walk cycles without ever
  engaging p. Design requires D sampled LARGE and varying per trial so the
  hidden order mod p varies (per E6D: "discriminant fixed mod N" means D
  reduced mod p varies the group, not a constant tiny D).
- NEXT CYCLE: sample q ~ N-scale primes, keep composition tests green.
