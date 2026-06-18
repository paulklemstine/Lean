**Research Brief: Carmichael’s Theorem — Composite-Index Primitive Prime Divisors via LTE**

Aristotle,

The file `Shared/CarmichaelProof.lean` contains the sorries that must be filled to complete the composite case of Carmichael’s theorem. The precise statement to prove is:

```lean4
theorem carmichael_composite_primitive_prime_divisor
    (n : ℕ)
    (hn : n > 12)
    (hcomp : ¬ n.Prime) :
    ∃ p : ℕ,
      p.Prime ∧
      p ∣ Nat.fib n ∧
      ∀ k : ℕ, 0 < k → k < n → ¬ p ∣ Nat.fib k
```

**Proof strategy — three steps:**

1. **LTE for the Fibonacci Lucas sequence.** First establish the Lifting-the-Exponent lemma for Fibonacci numbers: if `p` is an odd prime, `p ∣ F_m`, and `p ≠ 5`, then for every `e ≥ 1` we have `v_p(F_{m·p^e}) = v_p(F_m) + e`. Formalize this using `padicValNat` together with `Nat.fib_add` to handle the recurrence `F_{a+b} = F_{a-1}F_b + F_a F_{b+1}` and `padicValNat.add_eq_min` to compare valuations when the two summands have unequal `p`-adic order. This lemma is the core gadget that bounds how much any single “old” prime can contribute to the valuation of `F_n` when `n` is composite.

2. **Rank-of-apparition reduction via `fib_entry_point`.** For each prime `q` dividing `F_n`, invoke `fib_entry_point` (`Algebra/Algebra/OpenDirections.lean`) to obtain the least index `r(q) > 0` such that `q ∣ F_{r(q)}`. Prove that `r(q) | n`; under the no-primitive-divisor hypothesis we have `r(q) < n` for every `q`. Use `nontrivial_divisor_composite` (`Algebra/DivisionAlgebras/NormHierarchy.lean`) to turn this into a strict chain of proper divisors `d | n` with `1 < d < n`, and use `prime_has_divisor_one` (`Algebra/DivisionAlgebras/QuantumE8ModularForms.lean`) to discharge the degenerate case where `r(q) = 1` (which forces `q = 5`).

3. **Divisor stripping and multiplicative size bound.** Apply the existing `stripAllAux` procedure in `Shared/CarmichaelProof.lean` to remove prime-power factors from `n`. For each stripped layer, the LTE lemma limits the total exponent of every prime `q` in the product `∏_{d|n, d<n} F_d`. Finish with an elementary exponential inequality: for `n > 12` one has `F_n > ∏_{d|n, d<n} F_d`, which follows by induction using `fib_pos` and the growth estimate `fib_two_mul` (`Nat.fib_two_mul` in Mathlib) combined with strict monotonicity (`fib_lt_fib_succ`). Since LTE shows the product of the smaller Fibonacci numbers does not have enough `q`-adic volume to cover `F_n`, a primitive prime divisor must exist.

**Why this matters:** This fills the last outstanding gap in Carmichael’s theorem, confirming that every `F_n` with `n > 12` possesses a primitive prime divisor. Resolving it immediately gives a formal proof that every Fibonacci number beyond `F_12` introduces at least one new prime factor, completing a 100-year-old conjecture in elementary number theory and supplying the necessary arithmetic bound for the cross-direction correspondence program (tropical Feynman integrals and quantum error correction both rely on the primitive-divisor property for growth estimates).

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Algebra
Research mode: sorry_fill
