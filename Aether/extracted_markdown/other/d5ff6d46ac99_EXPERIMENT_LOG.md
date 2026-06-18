# Experiment Log — Running Record

## Successful Experiments

### Phase 1 (Original Project)
| # | Experiment | Result | Status |
|---|-----------|--------|--------|
| S1 | Universal compression impossibility | Proved via pigeonhole | ✅ |
| S2 | O(1) extraction equation | 8 operations suffice | ✅ |
| S3 | Toffoli determinant via permutation theory | det = -1 | ✅ |
| S4 | Pauli anticommutation | XZ = -ZX | ✅ |
| S5 | Hadamard conjugation | H swaps X ↔ Z | ✅ |
| S6 | Hamming code error detection | All columns nonzero & distinct | ✅ |
| S7 | Cassini's identity | F(n+1)² - F(n+2)·F(n) = (-1)ⁿ | ✅ |
| S8 | Cayley-Hamilton 2×2 | A² - tr(A)·A + det(A)·I = 0 | ✅ |
| S9 | Quadratic residues mod 5,7 | Complete classification | ✅ |
| S10 | Pell equation for √2 | Solutions (3,2) and (17,12) | ✅ |
| S11 | Fermat's little theorem | Verified for p = 3, 5, 7 | ✅ |

### Phase 2 (Iteration 2)
| # | Experiment | Result | Status |
|---|-----------|--------|--------|
| (See RESEARCH_PAPER2.md) | 70+ new theorems | All verified | ✅ |

### Phase 3 (Iteration 3 — Current)
| # | Experiment | Result | Status |
|---|-----------|--------|--------|
| S12 | Hockey stick identity | ∑ C(i+1,1) = C(n+2,2) by induction | ✅ |
| S13 | Pascal's rule | Nat.choose_succ_succ | ✅ |
| S14 | Binomial sum = 2ⁿ | Nat.sum_range_choose | ✅ |
| S15 | Handshaking lemma | n(n-1) = 2·C(n,2) | ✅ |
| S16 | Euler's theorem (general) | a^φ(n) ≡ 1 (mod n) | ✅ |
| S17 | Wilson's theorem | (p-1)! ≡ -1 (mod p) | ✅ |
| S18 | |S_n| = n! | Fintype.card_perm | ✅ |
| S19 | |S₃| = 6, |S₄| = 24 | native_decide | ✅ |
| S20 | Discrete metric triangle inequality | Case analysis | ✅ |
| S21 | Closed ⊂ compact ⟹ compact | IsClosed.isCompact | ✅ |
| S22 | [a,b] connected | isConnected_Icc | ✅ |
| S23 | Continuous image of connected | IsConnected.image | ✅ |
| S24 | Brouwer 1D fixed point | IVT on f(x)-x | ✅ |
| S25 | ℤ closed in ℝ | Sequence limit argument | ✅ |
| S26 | ℚ dense in ℝ | Rat.denseRange_cast | ✅ |
| S27 | Cantor's diagonal theorem | Diagonal argument | ✅ |
| S28 | AM-GM for two reals | √(ab) ≤ (a+b)/2 | ✅ |
| S29 | Cauchy-Schwarz (finite) | sum_mul_sq_le_sq_mul_sq | ✅ |
| S30 | Power mean inequality | nlinarith with sq_nonneg | ✅ |
| S31 | 1/n → 0 | tendsto_one_div_add_atTop | ✅ |
| S32 | Geometric series formula | geom_sum_eq | ✅ |
| S33 | Basel partial sums bounded | Summable comparison | ✅ |
| S34 | log(ab) = log(a) + log(b) | Real.log_mul | ✅ |
| S35 | H(1/2) = log(2) | Ring simplification | ✅ |
| S36 | Legendre symbol multiplicative | legendreSym.mul | ✅ |
| S37 | Totient multiplicative | Nat.totient_mul | ✅ |
| S38 | φ(p) = p-1 | Nat.totient_prime | ✅ |
| S39 | Perfect numbers 6, 28 | σ(6)=12, σ(28)=56 | ✅ |
| S40 | Pell convergents (4 pairs) | Direct computation | ✅ |
| S41 | Every n≥2 has prime factor | Nat.exists_prime_and_dvd | ✅ |
| S42 | Goldbach for 4,...,20 | Explicit witnesses | ✅ |
| S43 | Fermat's little (general) | ZMod.pow_card | ✅ |
| S44 | 5 and 6 are congruent | Explicit right triangles | ✅ |
| S45 | ℝ uncountable | Cardinal.not_countable_real | ✅ |
| S46 | No surjection α → 𝒫(α) | Cantor diagonal | ✅ |
| S47 | Schröder-Bernstein | Embedding antisymmetry | ✅ |
| S48 | ℕ well-ordered | Strong induction | ✅ |
| S49 | Ordinal add non-commutative | ω + 1 ≠ 1 + ω | ✅ |
| S50 | ℵ₀ + ℵ₀ = ℵ₀ | Cardinal arithmetic | ✅ |
| S51 | ℵ₀ · ℵ₀ = ℵ₀ | Cardinal arithmetic | ✅ |
| S52 | 2^ℵ₀ > ℵ₀ | Cardinal.cantor | ✅ |
| S53 | Markov inequality (discrete) | Sum comparison | ✅ |
| S54 | Ballot reflection principle | Binomial monotonicity | ✅ |
| S55 | √3 irrational | Nat.Prime.irrational_sqrt | ✅ |
| S56 | x² convex | nlinarith with t(1-t)(a-b)² | ✅ |
| S57 | Jensen's inequality (finite) | Via Cauchy-Schwarz | ✅ |
| S58 | P(Aᶜ) = 1 - P(A) | prob_compl_eq_one_sub | ✅ |
| S59 | Collatz from 27 reaches 1 | 111 steps, native_decide | ✅ |
| S60 | RSA roundtrip | 2^21 ≡ 2 (mod 33) | ✅ |
| S61 | 5 Platonic solids | Constraint enumeration | ✅ |
| S62 | Schur's theorem n=2 | native_decide | ✅ |
| S63 | Prime counting π(100) = 25 | native_decide | ✅ |

## Failed/Abandoned Hypotheses

| # | Hypothesis | Why Failed | Lesson |
|---|-----------|-----------|--------|
| F1 | O(1) universal compression | Impossible (pigeonhole) | Counting arguments are powerful |
| F2 | 8×8 det via native_decide | Memory overflow | Use structure (permutation theory) |
| F3 | Kolmogorov complexity computable | Halting problem reduction | Some things are fundamentally uncomputable |
| F4 | Catalan via recursive def + native_decide | Noncomputable termination | Use closed-form definitions for computation |
| F5 | ∆ notation for symmetric difference | Lean parser issue | Use `symmDiff` function name |
| F6 | ∧ without parens in norm_num | Type precedence mismatch | Always parenthesize conjuncts |
| F7 | Direct Fintype.card_sum application | Implicit argument issue | Use @ for explicit application |

## New Hypotheses to Explore

| # | Hypothesis | Area | Predicted Outcome |
|---|-----------|------|-------------------|
| H1 | Catalan(n) counts valid Berggren tree prunings | Combinatorics + NT | Likely true |
| H2 | The Berggren Cayley graph is Ramanujan for all primes | Spectral theory | Unknown |
| H3 | Every congruent number < 100 can be verified formally | BSD / NT | Feasible |
| H4 | Tunnell's criterion can be formalized in Lean | BSD / NT | Medium difficulty |
| H5 | Rule 110 universality proof in Lean | Computability | Very hard |
| H6 | Quadratic reciprocity from scratch | NT | Feasible with effort |
| H7 | Full Shannon source coding theorem | Info theory | Medium |
| H8 | Solovay-Kitaev bound | Quantum computing | Hard |
| H9 | Navier-Stokes weak solution existence (2D) | PDE | Very hard |
| H10 | Lattice basis reduction (LLL) in Lean | Crypto | Feasible |
