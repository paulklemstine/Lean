# E-8: Form-Composition Walk Demo — IN PROGRESS
Algorithm (per E6D_IDEA_ECM.md): D=-q fixed; random form f=[a,b,c] reduced;
iterate f <- f*f (NUDUPL squaring) then compose with a fixed base form, all
coefficients reduced mod N; after k steps gcd(a or c ± const, N) extracts p
when the hidden order's period divides the walk length. Pitfalls: ambiguous
forms need b-parity normalization; period unknown -> birthday-style restarts.
STATUS: design locked; implementation deferred one cycle (composition
arithmetic needs careful exact tests — see regex-incident lesson).
