# Computational evidence

The finite calculations relevant to the selected conjectures are small enough to be represented directly by the proved Lean objects.

| object | ambient ground set | family size | occupied ranks | weakly `B₃`-free? |
|---|---:|---:|---|---|
| maximal chain `fourRankChain` | 3 | 4 | 0, 1, 2, 3 | yes |
| full powerset of `Fin 3` | 3 | 8 | 0, 1, 2, 3 | no (contains a strong copy) |

The first row is the counterexample hunt: it refutes the universal claim that meeting four ranks forces a weak `B₃`. The second row shows that the rank profile alone does not decide cube containment.

No OEIS search was used: the investigation concerns finite poset containment rather than a newly identified integer sequence. The numerical facts in the table are reflected in `fourRankChain_rank_witness`, `fourRanks_do_not_force_weakB3`, and `powerset_containsStrongCube`; they are not being used as substitutes for proofs.
