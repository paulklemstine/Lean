# Future Directions — EML-Frege: Proof Checking, Arithmetization, and the Collapse Question

## Synthesis

The headline slogan of this research line — *"Proof Complexity Collapse: P=NP via
Proof Checking"* — rests on a real and important distinction (checking a proof is
not the same as searching for one) wrapped around a claim (a propositional proof
system in which **every** tautology has a polynomial-size proof) that, if true,
would give `NP = coNP`. That claim is open, almost certainly false, and not
something to assert. So this cycle did the honest and load-bearing thing: it
built and *machine-verified* the substrate any such program needs, and made the
remaining gap precise.

Concretely, in `Catalog/Logic/EMLFrege.lean` we formalized the
`{⊥, →}` propositional language and established two pillars with `sorry = 0`:

1. **The arithmetization bridge (logic ↔ field).** `Formula.arith` sends each
   formula to a real polynomial via the multilinear gadgets `¬x = 1-x`,
   `x∧y = x*y`, `x→y = 1 - x*(1-y)`. We proved it is an exact dictionary:
   `arith_eq_eval` (value on the cube equals `{0,1}`-embedded truth),
   `arith_boolean_valued` (`{0,1}`-valued on the cube), and
   `tautology_iff_arith` (tautology ⇔ identically 1 on the cube). This is what
   makes "verify a proof step by numeric evaluation" a meaningful, deterministic
   operation, and it is the natural meeting point with the catalog's EML calculus
   (`Catalog/EML/Defs.lean`: `EMLExpr`, `EMLExpr.eeval`, `PolyBoundedEML`).

2. **A sound, composable Frege calculus.** `Deriv` is a classical Hilbert system
   (`K`, `S`, `DNE`, modus ponens). We proved `Deriv.imp_self` (reflexivity via
   `SKK`), the **deduction theorem** `Deriv.deduction` (`Γ,a ⊢ b ⟹ Γ ⊢ a→b`,
   entirely from `K`/`S`), **soundness** `Deriv.soundness`, and its corollary
   `Deriv.theorem_tautology` (every theorem is a tautology). These connect to the
   structural complexity results in `Catalog/Logic/PvsNPFoundations.lean`
   (`ManyOneReducible`, `bool_diagonal_differs`, `oracle_barrier`).

## Results Summary

| Result | Statement | Status |
|---|---|---|
| `Formula.arith_eq_eval` | arithmetization = `{0,1}`-truth on the cube | proved |
| `Formula.arith_boolean_valued` | arithmetization is `{0,1}`-valued on the cube | proved |
| `Formula.tautology_iff_arith` | tautology ⇔ arithmetization ≡ 1 on the cube | proved |
| `Deriv.imp_self` | `Γ ⊢ a → a` | proved |
| `Deriv.imp_const` | `Γ ⊢ b ⟹ Γ ⊢ a → b` | proved |
| `Deriv.deduction` | deduction theorem | proved |
| `Deriv.soundness` | semantic soundness w.r.t. assumptions | proved |
| `Deriv.theorem_tautology` | theorems are tautologies | proved |

No axioms beyond `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Completeness of the `{⊥, →}` Frege calculus
The matching half of `Deriv.soundness` is still missing: **every tautology is
provable** (`Tautology f → Provable f`). The key insight is that completeness for
this exact axiomatization is reachable from what we already have — the deduction
theorem `Deriv.deduction` is the one nontrivial ingredient of Kalmár's lemma, and
`tautology_iff_arith` gives an algebraic handle on the induction. Why now: with
`deduction`, `imp_self`, and `imp_const` already verified, Kalmár's lemma reduces
to proving the per-literal cases `Γ_v ⊢ f` and `Γ_v ⊢ ¬f` by structural
induction on `f`, where `Γ_v` lists the literals of an assignment `v`. This is a
finite, falsifiable Lean target, not a conjecture.

### 2. Arithmetization size is linear, and certifies degree bounds
Conjecture: `Formula.arith` blows up size only linearly, i.e. the polynomial
produced has total degree and node-count `O(f.size)`, and its multilinear
reduction on the cube has degree `≤` the number of distinct variables. The key
insight is that `x→y = 1 - x*(1-y)` adds exactly one multiplication per `imp`
node, so degree grows additively along implication chains, not multiplicatively.
Why now: `arith` is already defined and `Formula.size` already exists in the file;
this is a clean inductive inequality (`arith`-degree `≤ size`) that turns the
qualitative bridge into a quantitative one — the first genuinely
*complexity-flavored* statement, and a prerequisite for any "short proof = small
polynomial certificate" argument.

### 3. Numeric proof-checking soundness over a finite field
Conjecture: replacing ℝ by `ZMod p` for a large prime `p` preserves the
arithmetization bridge for formulas of bounded size, so tautologyhood can be
*certified* by evaluating the polynomial at random points of `(ZMod p)ⁿ`
(Schwartz–Zippel). The key insight is that `arith_boolean_valued` already pins the
value to `{0,1}` on the cube, so a single off-by-one in a claimed proof becomes a
nonzero low-degree polynomial that fails at most points. Why now: the ℝ-valued
bridge is done and `{0,1}` lifts verbatim to any characteristic `> 2`; porting
`arith_eq_eval` to `ZMod p` is a mechanical re-run that immediately yields a
*probabilistically checkable* version of `tautology_iff_arith`.

### 4. The collapse claim, stated as a falsifiable separation target
Rather than asserting `NP = coNP`, formalize the precise negation that the
literature actually believes: there is **no** polynomial `q` such that every
tautology `f` has a `Deriv ∅`-proof of size `≤ q(f.size)`. The key insight is that
this is exactly a *Frege lower bound* statement, and it can be phrased entirely in
the vocabulary already in the file (`Provable`, a `Deriv`-size measure to be
added). Why now: with soundness/deduction verified, adding a `Deriv.size` function
makes "polynomially-bounded Frege" a definable predicate; one can then connect to
`Catalog/Logic/PvsNPFoundations.lean`'s `oracle_barrier` to formalize *why*
relativizing techniques cannot settle it — turning the hype into a precise,
testable barrier theorem.

### 5. Functor from Frege derivations to EML expression trees
Conjecture: there is a structure-preserving map (a functor on the obvious
categories) from `Deriv` proof trees to `EMLExpr` evaluation trees
(`Catalog/EML/Defs.lean`) that sends modus ponens to function composition and
each axiom to a constant-depth EML gadget, with `EMLExpr.esize` growing linearly
in proof size. The key insight is that both objects are free term algebras with a
single binary combinator (`imp` / `eml`), so the map is determined by where it
sends the generators. Why now: `EMLExpr`, `EMLExpr.esize`, and `EMLExpr.eeval`
already exist and are stable; defining the translation and proving an
`esize ≤ C * proofsize` bound is the concrete cross-domain bridge that the
original "EML-Frege" concept was reaching for — and the honest, provable core of
the "each proof step is an EML identity checked by evaluation" idea.
