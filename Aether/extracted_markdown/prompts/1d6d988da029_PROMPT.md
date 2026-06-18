Create a single self-contained Lean 4 file `Catalog/Computation/AutomaticSequences.lean` that formalizes a minimal, complete development of deterministic finite automata with output (DFAOs) and automatic sequences. The file must compile with no `sorry`, no placeholders, and no unrelated material.

Scope and strategy:
1. Keep the development tightly focused on finite-state arguments. Do not include Christol-style results, Turing computability, or any halting-problem discussion.
2. Define a DFAO over alphabet `Fin k` with finite state type `Q`, initial state `q0`, transition `step : Q → Fin k → Q`, and output `out : Q → α`.
3. Define evaluation on words `List (Fin k)` by folding transitions from `q0`, and define the output produced by a word.
4. Introduce a lightweight notion of `k`-automatic sequence `IsKAutomatic k f` for functions `ℕ → α`: it should assert existence of a DFAO and an encoding function `encode : ℕ → List (Fin k)` such that `f n` is the DFAO output on `encode n`. If convenient, package the encoder as a parameter rather than hardwiring `Nat.digits`; the point is to prove finite-state consequences, not digit arithmetic.
5. If you do use canonical base-`k` digits of naturals, keep that layer minimal and only use API already available in Mathlib. Do not let the project depend on difficult lemmas about digit expansions.

Required theorems to prove completely:
A. `IsKAutomatic.range_finite`: if `f : ℕ → α` is `k`-automatic and the DFAO state space is finite, then `Set.Finite (Set.range f)` (or equivalently a finite-set/range formulation). The proof should factor through the finite image of `out : Q → α`.
B. `DFAO.decidableOccurs`: for a fixed DFAO `M` and `a : α` with `DecidableEq α`, the proposition `∃ w : List (Fin k), M.eval w = a` is decidable by finite search over reachable states, or equivalently by checking whether some reachable state outputs `a`. If you prefer to phrase occurrence for an automatic sequence `f`, derive `Decidable (∃ n, f n = a)` from the chosen encoding and DFAO representation.
C. `Unary.eventuallyPeriodic`: define unary DFAOs (alphabet with one symbol, or equivalently a finite set `Q`, a self-map `next : Q → Q`, initial state, and output map) and prove the generated sequence `n ↦ out ((next^[n]) q0)` is eventually periodic. Use the standard finite-orbit repetition argument on iterates in a finite type.

Optional extension, only if it becomes easy after A:
D. Prove a general obstruction lemma: if `Set.range f` is infinite, then `f` is not `k`-automatic. Then deduce `¬ IsKAutomatic k (fun n : ℕ => n)` for any `k`. Do not attempt this unless the finite-range theorem is already complete and the proof is short.

Implementation guidance:
- Prefer simple definitions that make theorem A almost immediate.
- Use `Fintype`, `Finset`, `Set.Finite`, and images of finite sets rather than building custom machinery.
- For decidability, define reachable states as a set or finset obtained from all words, then use finiteness of the state type to decide whether some reachable state has output `a`.
- For unary eventual periodicity, use the pigeonhole principle on the finite sequence of iterates to find `i < j` with repeated state, then derive eventual periodicity with period `j - i`.
- Keep notation and namespace disciplined; do not append unrelated experiments.

Deliverable:
A polished standalone Lean file with explanatory module docstring, complete definitions, and complete proofs of A, B, C, plus D only if genuinely straightforward. If any part of the original plan around canonical base-`k` digits causes friction, simplify by parameterizing the encoding and finish the finite-state mathematics cleanly.