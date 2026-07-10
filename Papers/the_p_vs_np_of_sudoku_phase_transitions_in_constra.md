# Computational Evidence

The formal result of this project is:

> The chromatic number of the Sudoku constraint graph on an `n²×n²` grid equals `n²`
> (for `n ≥ 1`), and — equivalently, via the CSP ↔ graph-coloring bridge — every empty
> `n²×n²` Sudoku is solvable, witnessed by an explicit arithmetic filling.

Two computational checks support the proof.

## 1. The explicit filling is a valid Sudoku for small `n`

The construction used in `sudokuVal` is

```
sudokuVal n r c = (n * (r % n) + r / n + c) % (n * n)
```

We verified in Lean that the induced `n²×n²` grid satisfies **all** Sudoku constraints
(each row, each column, and each `n×n` block contains every symbol exactly once) for
`n = 2, 3, 4, 5`:

```lean
def f (n r c : Nat) : Nat := (n*(r % n) + r / n + c) % (n*n)
def nodup (l : List Nat) : Bool := l.dedup.length == l.length
def valid (n : Nat) : Bool := Id.run do
  let N := n*n
  for r in List.range N do
    if !nodup ((List.range N).map (fun c => f n r c)) then return false
  for c in List.range N do
    if !nodup ((List.range N).map (fun r => f n r c)) then return false
  for bA in List.range n do
    for bB in List.range n do
      let mut vals := []
      for i in List.range n do
        for j in List.range n do
          vals := f n (n*bA+i) (n*bB+j) :: vals
      if !nodup vals then return false
  return true
#eval [valid 2, valid 3, valid 4, valid 5]   -- [true, true, true, true]
```

Output: `[true, true, true, true]`. This confirms the upper-bound half of the theorem
(a proper `n²`-coloring exists) on concrete instances before it was proved in full generality.

## 2. Sanity check of the chromatic-number value

The lower bound `χ ≥ n²` is witnessed by a single full row: its `n²` cells are pairwise
in the same row, hence mutually adjacent, forming a clique of size `n²`. Since any graph
satisfies `χ(G) ≥ ω(G)` (clique number), `χ ≥ n²`. Combined with the explicit coloring
giving `χ ≤ n²`, we get `χ = n²`. For the standard `9×9` Sudoku (`n = 3`) this gives
`χ = 9`, matching the well-known fact that the Sudoku graph is `9`-chromatic.

## Relationship to the phase-transition framing

The original mission framing (a solution-probability phase transition at critical clue
density `d_c = (n²-1)/n²`) is an *empirical/asymptotic* statement about **random partially
filled** instances and is not a closed-form theorem. What is rigorously provable — and what
this project delivers — is the exact structural invariant underlying the CSP: the number of
symbols `n²` is simultaneously the chromatic number of the constraint graph. The clique of
size `n²` (a full row/column/block) is precisely the "hard core" of maximally mutually
constrained cells; it is the graph-theoretic object that forces the symbol count and around
which instance hardness concentrates. See `FUTURE_DIRECTIONS.md`.
