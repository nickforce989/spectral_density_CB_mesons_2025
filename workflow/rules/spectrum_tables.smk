import pandas as pd
from functools import partial


all_metadata = pd.read_csv("metadata/ensemble_metadata.csv")

metadata_query = "Nc == {Nc} & Nt == {Nt} & Ns == {Ns} & beta == {beta} & nF == {nF} & mF == {mF} & nAS == {nAS} & mAS == {mAS}"
metadata_lookup = partial(lookup, within=all_metadata, query=metadata_query)

dir_template = "Sp{Nc}b{beta}nF{nF}nAS{nAS}mF{mF}mAS{mAS}T{Nt}L{Ns}"

channels = ["ps", "v", "t", "av", "at", "s"]


def mpcac_data(wildcards):
    return [
        f"JSONs/{dir_template}/mpcac_mean.csv".format(**row)
        for row in metadata.to_dict(orient="records")
        if row["use_in_main_plots"]
    ]


def wall_mass_data(wildcards):
    return [
        f"JSONs/{dir_template}/meson_{channel}_mean.csv".format(channel=channel, **row)
        for row in metadata.to_dict(orient="records")
        for channel in channels
        if row["use_in_main_plots"]
    ]


def smear_mass_data(wildcards):
    return [
        f"JSONs/{dir_template}/smear_meson_{channel}_mean.csv".format(
            channel=channel, **row
        )
        for row in metadata.to_dict(orient="records")
        for channel in channels
        if row["use_in_main_plots"]
        if row["use_smear"]
    ] + [
        f"JSONs/{dir_template}/gevp_smear_meson_rhoE1_mean.csv".format(**row)
        for row in metadata.to_dict(orient="records")
        if row["use_in_main_plots"]
        if row["use_smear"]
    ]


def decay_constant_data(wildcards):
    return [
        f"JSONs/{dir_template}/decay_constant_{channel}_mean.csv".format(
            channel=channel, **row
        )
        for row in metadata.to_dict(orient="records")
        for channel in ["ps", "v", "av"]
        if row["use_in_main_plots"]
    ]


def wall_Rfps_data(wildcards):
    return [
        f"JSONs/{dir_template}/Rfps_{channel}_mean.csv".format(channel=channel, **row)
        for row in metadata.to_dict(orient="records")
        for channel in channels
        if row["use_in_main_plots"]
    ]


def smear_Rfps_data(wildcards):
    return [
        f"JSONs/{dir_template}/smear_Rfps_{channel}_mean.csv".format(
            channel=channel, **row
        )
        for row in metadata.to_dict(orient="records")
        for channel in channels
        if row["use_in_main_plots"]
        if row["use_smear"]
    ] + [
        f"JSONs/{dir_template}/gevp_smear_Rfps_rhoE1_mean.csv".format(**row)
        for row in metadata.to_dict(orient="records")
        if row["use_in_main_plots"]
        if row["use_smear"]
    ]


def smear_Rmv_data(wildcards):
    return [
        f"JSONs/{dir_template}/gevp_smear_Rmv_rhoE1_mean.csv".format(**row)
        for row in metadata.to_dict(orient="records")
        if row["use_in_main_plots"]
        if row["use_smear"]
    ]


def continuum_massless_extrapolation_mass(wildcards):
    return [
        f"JSONs/extrapolation_results/{channel}_extp_mass_mean.csv".format()
        for channel in ["v", "t", "av", "at", "s", "rhoE1"]
    ]


def continuum_massless_extrapolation_decay(wildcards):
    return [
        f"JSONs/extrapolation_results/{channel}_extp_decay_mean.csv".format()
        for channel in ["ps", "v", "av"]
    ]


def chipt_extrapolation_results(wildcards):
    return [
        f"JSONs/chipt_extrapolation_results/chipt_b{beta}_extp_mean.csv".format()
        for beta in [6.6, 6.65, 6.7, 6.75, 6.8]
    ]


def deft_extrapolation_results(wildcards):
    return [
        f"JSONs/deft_extrapolation_results/deft_b{beta}_extp_mean.csv".format()
        for beta in [6.6, 6.65, 6.7, 6.75, 6.8]
    ]


rule continuum_massless_decay:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        data=continuum_massless_extrapolation_decay,
        script="plateaus/tables/continuum_massless_decay.py",
    output:
        table="assets/tables/table_V_decay.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.data} --output_file {output.table}"


rule continuum_massless_mass:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        data=continuum_massless_extrapolation_mass,
        script="plateaus/tables/continuum_massless_mass.py",
    output:
        table="assets/tables/table_V_mass.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.data} --output_file {output.table}"


rule wall_mass_table:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        mass_data=wall_mass_data,
        mpcac_data=mpcac_data,
        decay_data=decay_constant_data,
        metadata_csv="metadata/ensemble_metadata.csv",
        script="plateaus/tables/wall_mass_table.py",
    output:
        table="assets/tables/table_VI.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.mass_data} {input.mpcac_data} {input.decay_data} --output_file {output.table}"


rule wall_mass_table2:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        mass_data=wall_mass_data,
        mpcac_data=mpcac_data,
        decay_data=decay_constant_data,
        metadata_csv="metadata/ensemble_metadata.csv",
        script="plateaus/tables/wall_mass_table2.py",
    output:
        table="assets/tables/table_VII.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.mass_data} {input.mpcac_data} {input.decay_data} --output_file {output.table}"


rule wall_mass_fps_table:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        data=wall_Rfps_data,
        script="plateaus/tables/wall_mass_fps_table.py",
    output:
        table="assets/tables/table_VIII.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.data} --output_file {output.table}"


rule smear_mass_table:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        data=smear_mass_data,
        script="plateaus/tables/smear_mass_table.py",
    output:
        table="assets/tables/table_IX.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.data} --output_file {output.table}"


rule smear_mass_fps_table:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        data=smear_Rfps_data,
        data_Rmv=smear_Rmv_data,
        script="plateaus/tables/smear_mass_fps_table.py",
    output:
        table="assets/tables/table_X.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.data} {input.data_Rmv} --output_file {output.table}"


rule chipt_table:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        data=chipt_extrapolation_results,
        script="plateaus/tables/chipt_table.py",
    output:
        table="assets/tables/table_XI.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.data} --output_file {output.table}"


rule deft_table:
    params:
        module=lambda wildcards, input: input.script.replace("/", ".")[:-3],
    input:
        data=deft_extrapolation_results,
        script="plateaus/tables/deft_table.py",
    output:
        table="assets/tables/table_XII.tex",
    conda:
        "../envs/flow_analysis.yml"
    shell:
        "python -m {params.module} {input.data} --output_file {output.table}"
