alias python_clean_cache='find . | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs rm -rf'

function pip_install() {
    for pkg in $@; do
        pip show $pkg &>/dev/null || pip install -U $pkg
    done
}

function python_clean_pip_conda_cache() {
    pip cache purge
    conda clean --all --yes
}

function python_check_tensorflow() {
    python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
}

function python_check_numa() {
    type -p numactl &>/dev/null || sudo apt-get install numactl
    numactl --show
}

function python_packaging_install_local() {
    pip show setuptools &>/dev/null || pip install setuptools
    [[ -d dist ]] && rm -r dist
    [[ -d build ]] && rm -r dist
    python -m build . --wheel
    pip install dist/*.whl --force-reinstall
}

function python_packaging_upload_testpypi() {
    pip show setuptools &>/dev/null || pip install setuptools
    pip show twine &>/dev/null || pip install twine
    [[ -d dist ]] && rm -r dist
    [[ -d build ]] && rm -r dist
    rm -rf ./*.egg-info
    python -m build . --wheel
    twine check dist/*
    twine upload --repository testpypi dist/*
}

function python_packaging_upload_pypip() {
    pip show setuptools &>/dev/null || pip install setuptools
    pip show twine &>/dev/null || pip install twine
    [[ -d dist ]] && rm -r dist
    [[ -d build ]] && rm -r dist
    python -m build . --wheel
    twine check dist/*
    twine upload dist/*
}

function python_pyright_stubs_from_requirements_txt() {
    pip show pyright &>/dev/null || pip install twine
    pip show requirements-parser >/dev/null || pip install requirements-parser
    local pkgs=$(python -c "import requirements; import os; names=[req.name for req in requirements.parse(open('requirements.txt', 'r'))]; print(' '.join(names))")
    for pkg in $pkgs; do
        pyright --createstub $pkg
    done
}
