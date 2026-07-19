# Why computational evidence was skipped

The principal theorem concerns the nonexistence of a countable local basis in the order topology on Conway's surreal numbers. It is intrinsically infinitary and depends on the Conway-cut construction: from an arbitrary sequence of positive surreals one constructs a new positive surreal below every term. No finite sample can provide meaningful evidence for this universal diagonal statement, and surreal numbers in Mathlib are quotient objects rather than a finite executable enumeration. The proof is therefore structural rather than experimental.

Likewise, disconnectedness and noncompactness here follow from symbolic order-theoretic witnesses (a proper clopen cut and absence of a greatest element), not numerical data or a sequence suitable for OEIS comparison.
