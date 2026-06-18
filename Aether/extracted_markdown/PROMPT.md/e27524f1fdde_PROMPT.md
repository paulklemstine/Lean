Formalize a single self-contained Lean 4 theorem file proving the following arithmetic bridge toward Korselt's criterion:

For n p : ℕ, assume hp : p.Prime, hpn : p ∣ n, hn : n ≠ 0, and
hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1.
Prove:
  p - 1 ∣ n - 1.

Scope restrictions:
1. Produce exactly one new file.
2. The file must fully compile with 0 sorries, 0 admits, and no placeholder declarations.
3. Do not create a second file of partial lemmas, sketches, or future plans.
4. Keep the development narrowly focused on this theorem and only introduce helper lemmas that are actually used.

Required proof strategy:
- Use the reduction map on units induced by p ∣ n, i.e. the existing ZMod units map from (ZMod n)ˣ to (ZMod p)ˣ, together with its surjectivity.
- Transport the hypothesis hpow along this surjection to show:
    ∀ v : (ZMod p)ˣ, v ^ (n - 1) = 1.
- Conclude that the exponent, or at least the order of every element, in (ZMod p)ˣ divides n - 1.
- Use existing mathlib facts about the multiplicative group of a finite field / ZMod p to derive that p - 1 divides n - 1.
- Avoid any route that requires explicitly choosing a generator and developing ad hoc cyclic-group infrastructure unless such lemmas already exist and make the proof shorter.

Implementation guidance:
- Prefer existing mathlib lemmas about orderOf, exponent, cyclicity, cardinality of units of ZMod p, and surjective monoid homs on units.
- If a small helper lemma is needed, keep it local and fully proved.
- The final theorem statement should be mathematically clean and directly reusable by later Korselt/Carmichael developments.

Deliverable:
- One complete Lean file containing imports, a brief module docstring, any tiny helper lemma(s), and the final theorem.
- No unfinished extensions beyond this bridge lemma.

Success criterion:
A reviewer should be able to inspect one file and see a complete, nontrivial, type-checking formalization of the bridge lemma with no speculative scaffolding.