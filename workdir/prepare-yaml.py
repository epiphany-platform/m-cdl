#!/bin/env python3
import yaml
import itertools

from jinja2 import Environment, FileSystemLoader


def yaml_as_python(val):
    try:
        return yaml.load_all(val, yaml.FullLoader)
    except yaml.YAMLError as exc:
        return exc


template_env = Environment(loader=FileSystemLoader(searchpath="./"))
template = template_env.get_template('template.yml.j2')


def group_by_kind(x):
    return x['kind']


with open('manifest.yml', 'r') as input_file:
    results = yaml_as_python(input_file)

    dict = {
        g[0]: [i for i in g[1]]
        for g in itertools.groupby(results, group_by_kind)
    }

    generated = template.render(Values=dict)

    print(generated)
