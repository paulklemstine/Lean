# The Price of Forgetting: Proofs, Information, and Heat

## A seductive equation—and the question behind it

A mathematical proof can be tiny or enormous. A computer can check one in a blink or spend years searching for it. A physical machine performing either task must store bits, move charges, and eventually reuse memory. It is tempting to compress all of this into one slogan: a proof has a thermodynamic cost equal to its algorithmic information.

The idea becomes precise only after several distinctions are made. Fix a binary description language, let $K(\pi)$ be the length in bits of the shortest self-delimiting program that prints a proof $\pi$, and let $T>0$ be an absolute temperature measured in energy units. Define the **description-erasure scale**

$$
C_T(\pi)=T\ln(2)\,K(\pi).
$$

If ordinary temperature is measured in kelvin, the physical energy scale is $k_{\mathrm B}T\ln(2)\,K(\pi)$, where $k_{\mathrm B}$ is Boltzmann’s constant. The factor $T\ln(2)$ is the Landauer scale for erasing one bit.

This definition gives a clean theorem: if $K(\pi_1)\le K(\pi_2)$, then $C_T(\pi_1)\le C_T(\pi_2)$. In words, a proof with a shorter minimal description has no larger description-erasure scale. But the careful wording matters. The theorem compares shortest descriptions, not necessarily the visible number of symbols on a page; it assigns a scale to information, not the unavoidable heat of every implementation; and it does not say that proof search takes only that much energy.

Those caveats are not technical debris. They are where the interesting science begins.

## Three costs hiding under one name

Imagine a theorem whose shortest proof occupies a thousand bits. There are at least three different questions one might ask.

First, **description complexity** asks how concisely the proof can be generated. That is what $K(\pi)$ measures. It is a property of the proof relative to a fixed universal language, up to an additive language-dependent constant.

Second, **search work** asks how many candidates must be explored before the proof is found. A proof may have a short description yet be hidden at the end of a vast search. Conversely, a long proof might be generated directly by a simple repetitive program.

Third, **logical erasure** asks how much information a physical computation discards. Landauer’s principle constrains logically irreversible operations: when a device merges distinguishable states and later resets its memory, heat must be exported. A reversible verifier can, in principle, retain enough history to avoid that merging, trading heat for memory and time.

These quantities can correlate, but they are not identical. Confusing them is like confusing the length of a treasure map, the time needed to find the treasure, and the fuel burned on the journey.

## Counting creates incompressible proofs

Algorithmic information enters through a simple counting fact. For a prefix-free binary language, fewer than $2^m$ programs have length below $m$. Therefore, in any finite family of $N$ distinct objects, fewer than $2^m$ can have descriptions shorter than $m$ bits. Equivalently, at least $N-2^m$ members require complexity at least $m$.

This is the **finite incompressibility theorem**. It says that short descriptions are scarce. If a family has $N=2^n$ distinguishable members and we choose one uniformly, then for any integer $c\ge 1$, at least a fraction $1-2^{-c}$ have complexity at least $n-c$. Most members lie close to the full $n$-bit scale.

Multiplying by $T\ln(2)$ immediately yields a thermodynamic corollary: most members have description-erasure scale at least $T\ln(2)(n-c)$. The lower bound is linear in $n$.

That linear growth corrects a tempting but mistaken claim. A family of $2^n$ possible statements does not force the average shortest-description cost to be of order $2^n$. Under uniform sampling from $n$-bit objects, a standard self-delimiting encoding gives complexity at most $n+O(\log n)$, while incompressibility puts the mean near $n$. Thus the natural average description cost is $\Theta(n)$, not $\Theta(2^n)$.

Where, then, can exponential behavior appear? In search. Exhaustively examining all descriptions up to length $n$ involves on the order of $2^n$ candidates. The number of candidates is exponential even though each successful description has only linear length. The distinction between the size of an answer and the effort needed to locate it is the central lesson.

## Sorting as a physical parable

Sorting gives a concrete model in which information, decision depth, reversible memory, and heat can all be compared without speculation.

There are $n!$ possible orderings of $n$ distinct objects. A binary comparison tree of height $h$ has at most $2^h$ leaves, so any tree capable of distinguishing every ordering must satisfy

$$
n!\le 2^h,
$$

and hence

$$
h\ge \lceil\log_2(n!)\rceil.
$$

The same factorial controls the information forgotten by sorting. Once the objects have been placed in increasing order, the output alone no longer records which of the $n!$ input permutations was supplied. Under a uniform input model, that lost label carries exactly $\log_2(n!)$ bits. Resetting it irreversibly has the Landauer scale

$$
T\ln(2)\log_2(n!)=T\ln(n!).
$$

A reversible implementation cannot simply destroy the label. It must preserve enough auxiliary history to distinguish at least $n!$ possibilities. In this way, one combinatorial quantity governs three lower bounds: comparison depth, erased information, and reversible history capacity.

Yet comparison count is not heat. Take any valid comparison tree and place $r$ redundant comparison levels above it, duplicating the same subtree after either outcome. The new tree remains capable of sorting, and its height rises by exactly $r$. Nevertheless, the mathematical sorting map has not changed, so the information that map forgets remains $\log_2(n!)$ bits. Redundant operations may consume energy in a real device, but that consumption cannot be inferred from logical erasure alone.

For $n=10$, there are $10!=3{,}628{,}800$ possible orders. At least $22$ binary comparisons are needed in the worst case because $2^{21}<10!\le 2^{22}$. The erased permutation label contains about $21.79$ bits. At room temperature, its ideal Landauer energy is extraordinarily small—but not zero. The important point is conceptual: the lower bound belongs to discarded distinctions, not to the mere tally of instructions.

## The shortest proof and the longest search

Return now to proof. Suppose a proof checker maps many candidate bit strings to a simple verdict such as “accepted.” If the checker erases the candidate and its work tape after returning that verdict, it has merged many physical histories. A reversible checker can avoid immediate erasure by retaining the candidate and intermediate states, then copying the verdict and running backward to clean its workspace. This is the reversible-computation strategy often called uncomputation.

The proof’s Kolmogorov complexity tells us how many bits suffice to regenerate it. If those bits are eventually erased, $T\ln(2)K(\pi)$ is the corresponding ideal scale. But verification may use additional temporary memory; search may inspect an enormous rejected set; and a particular circuit may dissipate far more than the Landauer minimum. The formula is therefore best read as an information benchmark, not as a universal energy meter.

A second subtlety is that $K$ is not computable. If a general algorithm could always determine the shortest description, it could be turned against itself by diagonal constructions. Consequently, the scale $C_T$ is mathematically definite but cannot be evaluated exactly for arbitrary proofs. Practical studies must use upper bounds supplied by compressors, proof languages, or restricted description systems.

This uncomputability also motivates a proof-theoretic conjecture: in a sufficiently expressive, sound, computably axiomatized theory, no computable function should uniformly bound the shortest-proof complexity of all theorems whose statements have length at most $n$. A Chaitin-style argument suggests why. A computable universal bound would make extreme incompressibility effectively searchable; self-reference would then manufacture an object certified to outrun the very bound used to find it. Turning this intuition into a theorem requires fixing the theory, the statement encoding, the proof system, and the prefix-free language with great care.

## Why this matters for machine intelligence

Machine-learning systems increasingly generate programs, proofs, explanations, and plans. They face the same separation between representation and search. A compact certificate may sit behind an expensive training run. A model may emit a long derivation from a short latent rule. Verification may be cheap even when discovery is hard.

The thermodynamic viewpoint offers a disciplined vocabulary. Description complexity measures compressibility. Search complexity measures exploration. Logical irreversibility measures information discarded by a computation. Physical dissipation depends on how hardware realizes those logical steps. These layers should be connected by explicit assumptions, not collapsed into a single number.

This perspective suggests practical design principles. Preserve provenance when memory permits, so computations can be uncomputed rather than erased. Separate the energy of verification from the energy of discovery. Treat proof compression as a potential reduction in storage and reset cost, while recognizing that finding the compression may itself be expensive. Measure the multiplicity of a verifier’s fibers—the number of inputs producing the same output—because this multiplicity quantifies both information loss and the history capacity needed for reversibility.

## A measured conclusion

The strongest message is not that every proof carries a fixed physical price tag. It is subtler and more useful.

A shortest description of $K$ bits defines an information scale of $T\ln(2)K$. This scale is monotone: lower complexity means lower description-erasure cost. Counting shows that most objects in a uniform $2^n$-member family need nearly $n$ bits, giving linear average description cost. Exponential growth belongs naturally to exhaustive search over descriptions, not to their average length. Sorting demonstrates the same architecture in a transparent setting: $n!$ controls decision depth, lost information, and reversible memory, while redundant comparisons prove that operation count and Landauer cost are different quantities.

The physics of reasoning is therefore a physics of distinctions. Heat appears not because a theorem is profound or a proof is long, but because a machine chooses to forget. The grand challenge is to map exactly which distinctions must be retained, which may be compressed, and which are irreversibly erased on the road from question to proof.