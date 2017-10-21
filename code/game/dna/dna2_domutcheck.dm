// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// M: Mob to mess with
// connected: Machine we're in, type unchecked so I doubt it's used beyond monkeying
// flags: See below, bitfield.
/proc/domutcheck(var/mob/living/M, var/connected=null, var/flags=0)
	if(!M || !M.dna || isemptylist(M.dna.SE_structure))
		return	
	var/ind = 0
	for(var/x in M.dna.SE_structure)
		ind += 1
		if(istype(x, /datum/dna/gene))
			domutation(x, M, connected, flags, ind)
// Does nothing!
/proc/genemutcheck(var/mob/living/M, var/block, var/connected=null, var/flags=0)
	domutcheck(M, connected, flags)

/proc/genemutcheckold(var/mob/living/M, var/block, var/connected=null, var/flags=0) // depricated
	if(ishuman(M)) // Would've done this via species instead of type, but the basic mob doesn't have a species, go figure.
		var/mob/living/carbon/human/H = M
		if(H.species.flags & NO_DNA)
			return
	if(!M)
		return
	if(block < 0)
		return

	var/datum/dna/gene/gene = assigned_gene_blocks[block]
	domutation(gene, M, connected, flags)


/proc/domutation(var/datum/dna/gene/gene, var/mob/living/M, var/connected=null, var/flags=0, var/block=0)
	if(!gene || !istype(gene))
		return 0

	// Sanity checks, don't skip.
	if(!gene.can_activate(M,flags))
		//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
		return 0

	// Current state
	var/gene_active = (gene.flags & GENE_ALWAYS_ACTIVATE)
	if(!gene_active)
		if(block)
			gene_active = M.dna.GetSEState(block)
		else
		//	gene_active = M.dna.GetSEState(gene.block)
			return
	var/defaultgenes // Do not mutate inherent species abilities
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		defaultgenes = H.species.default_genes

		if((gene in defaultgenes) && gene_active)
			return

	// Prior state
	var/gene_prior_status = (gene.type in M.active_genes)
	var/changed = gene_active != gene_prior_status || (gene.flags & GENE_ALWAYS_ACTIVATE)

	// If gene state has changed:
	if(changed)
		// Gene active (or ALWAYS ACTIVATE)
		if(gene_active || (gene.flags & GENE_ALWAYS_ACTIVATE))
			//testing("[gene.name] activated!")
			gene.activate(M,connected,flags)
			if(M)
				M.active_genes |= gene.type
		// If Gene is NOT active:
		else
			//testing("[gene.name] deactivated!")
			gene.deactivate(M,connected,flags)
			if(M)
				M.active_genes -= gene.type
