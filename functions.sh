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
    echo `basename $log .log` | cut -d - -f 2
}

function log_impl() {
    log=${1:?}
    echo `basename $log .log` | cut -d - -f 1
}

function log_exec() {
    echo implementations/`log_impl $1`/btm
}

function run_script() {
    impl=${1:?}
    script=${2:?}
    log=${3:?}
    logdir=`dirname $log`
    logbase=`basename $log .log`
    header="$impl / $script"
    
    echo
    echo "============================================================"
    echo "Running $header"
    echo "------------------------------------------------------------"

    ./scripts/$script ./implementations/$impl/btm | tee $log

    if [ $? == 0 ]; then
        result=SUCCESS
    else
        result=FAILURE
    fi
    ln -s $logbase.log $logdir/$logbase.$result.log

    echo
    echo "------------------------------------------------------------"
    echo "$result running $header"
    echo "============================================================"

}


