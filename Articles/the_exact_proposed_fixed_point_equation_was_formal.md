# When Self-Reference Stores Data: A Tale of Two Fixed-Point Equations

Self-reference has a reputation for causing trouble. A sentence that speaks about itself evokes paradox; a program that consumes its own description suggests undecidability; a system defined in terms of all its possible observations can sound like the beginning of an infinite hierarchy. Yet self-reference is not a single mathematical phenomenon. Its behavior depends sharply on what kind of information is allowed to circulate through the loop.

A particularly clean example begins with a type, or set of possible states, $T$. For each state $x\in T$, assign a fiber $F(x)$: the collection of values that may be stored above $x$. A section chooses one value from every fiber. The space of all sections is the dependent product

$$
\prod_{x\in T} F(x).
$$

We call $T$ a **data-valued dependent-product fixed point** if some family $F$ makes $T$ equivalent, by a reversible one-to-one translation, to its own section space:

$$
T\simeq \prod_{x\in T}F(x).
$$

At first glance this equation resembles a hall of mirrors: an element of $T$ is interchangeable with an entire assignment indexed by all elements of $T$. But the equation can be surprisingly concrete. Its meaning is not that a state literally contains copies of itself. Rather, each state can encode exactly one globally compatible choice of fiber values, and every such choice decodes to exactly one state.

The decisive issue is whether fibers contain proofs or data.

## The version that collapses

Suppose first that every fiber $P(x)$ is a proposition. A section then chooses a proof of $P(x)$ for each $x$. Proofs of the same proposition carry no distinguishable data: whenever two proofs establish the same proposition, they count as equal for the purpose of this construction. Consequently, any two sections of

$$
\prod_{x\in T}P(x)
$$

must agree at every coordinate. The section space has at most one element.

If $T$ is equivalent to that section space, then $T$ also has at most one element. The equation itself rules out emptiness. Indeed, if $T$ were empty, the dependent product over $T$ would contain the unique empty section, so an empty set could not be equivalent to it. Therefore $T$ has exactly one element.

This gives the **Proposition-Valued Collapse Theorem**: a type $T$ satisfies

$$
\exists P:T\to\mathrm{Prop},\qquad T\simeq\prod_{x\in T}P(x)
$$

if and only if $T$ is equivalent to a singleton.

Several consequences follow immediately. Every such $T$ has decidable equality; all such fixed points are mutually equivalent; each has cardinality one; and every predicate on such a type is constant in extension, because there is only one possible argument. The singleton is a concrete counterexample to any claim that the equation forces undecidability. The equation does not create an arithmetical hierarchy: up to equivalence, it creates one object.

This collapse is not a failure of self-reference. It is a diagnosis. The loop has been built from fibers that cannot retain distinguishable information.

## Opening the fibers

Now replace proposition-valued fibers by ordinary data types. Nothing says that two values in $F(x)$ must be indistinguishable. The old collapse argument immediately loses its force.

The smallest revealing example uses the two-element set

$$
T=\{\mathsf{false},\mathsf{true}\}.
$$

Define a family of fibers by

$$
F(\mathsf{false})=\{\mathsf{false},\mathsf{true}\},
\qquad
F(\mathsf{true})=\{\star\}.
$$

The first fiber stores one bit. The second stores nothing beyond its unique token $\star$. A section consists of a pair of choices: one Boolean value above $\mathsf{false}$ and the forced value $\star$ above $\mathsf{true}$. Thus there are exactly two sections.

More importantly, the equivalence is explicit. Given a Boolean $a$, encode it as the section $s_a$ defined by

$$
s_a(\mathsf{false})=a,
\qquad
s_a(\mathsf{true})=\star.
$$

Given a section $s$, decode it by reading its informative coordinate:

$$
s\longmapsto s(\mathsf{false}).
$$

Decoding an encoded Boolean returns the original Boolean. Encoding a decoded section returns the original section, because its value at $\mathsf{false}$ is preserved and its value at $\mathsf{true}$ had no freedom to begin with.

This proves the **Boolean Data Fixed-Point Theorem**: the two-element type is equivalent to the section space of the family with a two-element fiber over $\mathsf{false}$ and a singleton fiber over $\mathsf{true}$.

The example is not a disguised constant function space. Its two fibers have different cardinalities, $2$ and $1$, so no bijection can identify them. The dependence on the base point is essential. Nor is the section space a singleton: the sections encoding $\mathsf{false}$ and $\mathsf{true}$ are distinct. This proves a broader negative conclusion, the **Non-Collapse Theorem**: data-valued dependent-product fixed points need not be singletons.

## The arithmetic shadow

For finite sets, the abstract equivalence casts a simple numerical shadow. If $T$ is finite and each fiber $F(x)$ is finite, then choosing a section means making one independent choice in every fiber. The multiplication principle gives

$$
\left|\prod_{x\in T}F(x)\right|
=
\prod_{x\in T}|F(x)|.
$$

Therefore every finite data-valued fixed point satisfies the **Finite Cardinality Product Theorem**:

$$
|T|=\prod_{x\in T}|F(x)|.
$$

For the Boolean example this reads

$$
2=2\cdot 1.
$$

The equation looks modest, but it reveals how information is distributed. Cardinality measures the total number of global states. Each fiber contributes a local multiplicative factor. Singleton fibers are silent coordinates: they add an index but no choice. A non-singleton fiber carries information. In the Boolean construction, all information is concentrated at one point.

This resembles sparse data representation. A large record may have many fields, while only a few fields vary and the rest are fixed defaults. It also resembles a communication channel: the base set lists possible addresses, but capacity is supplied only by addresses whose fibers contain alternatives. The logarithmic form makes the analogy vivid. When all cardinalities are positive,

$$
\log |T|=\sum_{x\in T}\log |F(x)|.
$$

The information content of the global state is the sum of the information capacities of its fibers.

The product equation is necessary, but cardinality alone does not display the encoding. A genuine fixed-point construction also needs explicit reversible maps between states and sections. In finite settings, equal cardinalities guarantee that some bijection exists, but a meaningful model should explain where the data live and how they are recovered. The Boolean example does both.

## Why constant fibers are different

If every fiber is the same finite set $A$, the equation becomes

$$
T\simeq (T\to A),
$$

and cardinalities must satisfy

$$
n=a^n,
$$

where $n=|T|$ and $a=|A|$. For $n\ge 2$ and $a\ge 2$, the right-hand side grows too large: already $a^n\ge 2^n>n$. Thus nontrivial finite solutions cannot come from constant fibers of size at least two. Dependence is not ornamental; it is the mechanism that permits small fixed points.

The Boolean construction evades exponential growth by using one fiber of size $2$ and one of size $1$, producing $2\cdot1$ rather than $2^2$. More generally, a natural design principle is to choose a distinguished point, place all $n$ possible values in its fiber, and use singleton fibers elsewhere. The product is then $n$. This strongly suggests finite examples of every positive size and genuinely unequal fibers whenever $n\ge2$.

Prime cardinalities promise an especially sharp classification. If $|T|=p$ is prime and all fibers are finite, then

$$
p=\prod_{x\in T}|F(x)|.
$$

Provided no fiber is empty, unique factorization forces exactly one factor to equal $p$ and all others to equal $1$. The Boolean case is the first prime instance, with $p=2$.

## A tiny model with broad connections

The same pattern appears whenever a system has many named locations but only a few meaningful degrees of freedom. In a configuration file, most fields may be fixed defaults while one field selects an operating mode. In a network protocol, one message kind may carry a payload while another carries only an acknowledgement. In a state machine, several coordinates may be present for uniformity even though only one records change. The dependent-product viewpoint separates the *shape* of a record from its *capacity*: every index remains visible, but singleton fibers announce that no choice is available there.

This perspective also warns against measuring complexity by the number of coordinates alone. The Boolean model has two coordinates, yet only one bit of freedom. A hundred singleton coordinates would add no new sections. What matters is the product of local alternatives—or, after taking logarithms, their summed information. Dependence lets a model state precisely which locations are informative and which are structurally present but silent.

## What self-reference actually needs

The contrast between the two equations carries a general lesson. Syntactic resemblance does not determine logical behavior. Both constructions ask a space to match a dependent product indexed by itself. Yet proposition-valued fibers erase distinctions, while data-valued fibers preserve them. One version collapses to a singleton; the other already supports a nontrivial two-state system.

This also clarifies why genuine incompleteness and undecidability require more machinery than a bare fixed-point equation. Gödel-style phenomena depend on effective syntax, coding, substitution, a semantics or provability relation, and a precise notion of computable decision procedure. Without those ingredients, the word “undecidable” can drift between several meanings. Self-reference is part of the story, but it is not the whole story.

The next mathematical frontier is therefore not to attach grander claims to the original equation, but to classify the richer one. Which finite cardinal patterns arise? When must a family be genuinely dependent? Which infinite types admit a concentrated-information construction? How do explicit encoders behave when equality in the base is computable? And what changes when fibers interact rather than contributing independent choices?

A one-bit example answers the foundational question. Data-valued dependent products do not inevitably collapse. The smallest nontrivial fixed point is built not by spreading information everywhere, but by placing one bit in exactly one fiber and letting every other coordinate remain silent. Sometimes the way out of a hall of mirrors is simply to give one mirror memory.
