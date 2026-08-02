# Why computational evidence was skipped

The principal claims are structural equivalences about arbitrary preorders, Galois connections, closure systems, and the Zariski topology. They do not produce a numerical sequence or a meaningful finite table, so an OEIS search or plot would not test the universal statements.

The one finite issue—the claim that every order-theoretic closure operator is topological—is handled more strongly than a search: `Catalog/Bridges/GaloisTopologyBridge.lean` gives an explicit closure operator on the three-element type `Fin 3` and a kernel-checked proof that it violates preservation of binary unions.
