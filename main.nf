params.in_file = "$baseDir/data/species.fasta"

process Split {

    publishDir params.results+params.upper_seq_dir, mode: "symlink"

    input:
    path in

    output:
    path 'seq_*'

    script:
    """
    cat $in | awk '/^>/{f="seq_"++d".txt"} {print > f}'
    """
}

process Lower {

    publishDir params.results+params.lower_seq_dir, mode: "symlink"

    input:
    each path(seq)
    
    output:
    path "${seq.baseName}_low.txt"

    script:
    println "Lower: $seq"
    """
    awk '{ print tolower(\$0) }' $seq > ${seq.baseName}_low.txt
    """

}

process Replace {
    
    conda "$baseDir/dependencies/sd_env.yml"
    publishDir params.results+params.replace_seq_dir, mode: "symlink"
    
    input:
    each path(seq)

    script:
    """
    sd 'sequence' 'species' $seq
    """ 
}

log.info """\
=============================================================
NEXTFLOW DEMO RUN
=============================================================
base dir                $baseDir
input data              $params.in_file
-------------------------------------------------------------
"""

workflow{
    Split(params.in_file)
    Lower(Split.out)
    Replace(Split.out)
}