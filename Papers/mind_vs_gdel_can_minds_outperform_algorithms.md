# Computational Evidence: Incompressibility and the Diagonal Fixed Point

Before formalising, we checked the two quantitative claims underlying this cycle.

## 1. The Berry / Chaitin counting bound

**Claim tested.** With complexity `K(x) = Nat.size(enc x)` for an injective code `enc`, among
any `2^n + 1` numbers at least one has `K(x) > n`, and complexity is unbounded.

**Small cases (identity code `enc = id`, so `K(x) = number of binary digits of x`).**

| x | binary | K(x) = Nat.size x |
|---|--------|-------------------|
| 0 | 0      | 0 |
| 1 | 1      | 1 |
| 2 | 10     | 2 |
| 3 | 11     | 2 |
| 4 | 100    | 3 |
| 7 | 111    | 3 |
| 8 | 1000   | 4 |
| 15| 1111   | 4 |

Count of numbers with `K(x) ≤ n`: `n = 0 → {0}` (1 value); `n = 1 → {0,1}` (2);
`n = 2 → {0,1,2,3}` (4); `n = 3 → {0..7}` (8). In general exactly `2^n` values satisfy
`K(x) ≤ n`, i.e. `Nat.size x ≤ n ↔ x < 2^n`. Hence in `{0, …, 2^n}` (which has `2^n + 1`
elements) at least one exceeds the `2^n` slots — the finite Berry pigeonhole — and letting
`n → ∞` shows `K` is unbounded. This is exactly the arithmetic lemma `Nat.size_le` that the
Lean development is built on.

**Counterexample hunt.** Dropping injectivity breaks the claim immediately: the constant code
`enc = fun _ => 0` gives `K(x) = 0` for all `x`, so no number is incompressible. This confirms
injectivity is the essential hypothesis, matching the Critique note in the Lean file.

**Sequence note.** The step function `n ↦ #{x | Nat.size x ≤ n} = 2^n` is the powers of two,
OEIS A000079; the digit-length function `Nat.size` itself matches the "number of bits of n"
sequence OEIS A070939 (offset aside). No surprising sequence appears — the landscape is the
clean exponential expected from a counting argument, so we proceeded directly to the formal
pigeonhole proof.

## 2. The diagonal fixed point

**Claim tested.** A point-surjective `φ : A → (A → Prop)` forces every `f : Prop → Prop` to
have a fixed point `p ↔ f p`; with `f = ¬` this is a contradiction, so no such `φ` exists
(Cantor/Tarski).

**Finite check.** For `A = Fin k` there are `2^(2^k)` functions `A → Bool` but only `k`
indices, so `φ` can hit at most `k < 2^(2^k)` of them — point-surjectivity already fails by
counting for every `k ≥ 1`. The diagonal element `a ↦ ¬ φ(a)(a)` is precisely one of the
missed functions. This finite calculation is the shadow of the infinite Lawvere argument and
gave us confidence the fixed-point construction is correct before formalising it.

## Conclusion

Both quantitative kernels behave exactly as the paradoxes predict, with no anomalies and one
clean counterexample delimiting the injectivity hypothesis. The computational landscape being
fully understood, we moved to the formal proofs in `LucasPenroseGodel.lean` and
`ChaitinBerry.lean`.
