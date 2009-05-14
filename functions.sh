function impl_logs() {
    impl=${1:?Implementation path/name required!}
    impl_name=`impl_name $impl`
    for script in `script_names`; do echo "log/${impl_name}-${script}.log"; done
}

function impl_name() {
    impl=${1:?Implementation path/name required!}
    basename $impl
}

function script_names() {
    ls scripts
}

function log_script() {
    log=${1:?}
    echo `basename $log .log` | cut -d _ -f 2
}

function log_impl() {
    log=${1:?}
    echo `basename $log .log` | cut -d _ -f 1
}

function run_script() {
    impl=${1:?}
    script=${2:?}
    log=${3:?}

    scripts/$script implementations/$impl | tee > $log
}


