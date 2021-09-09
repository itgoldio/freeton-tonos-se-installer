#!/bin/bash
#set -x	

LOG_INFO_PREFIX="INFO:"
LOG_WARNING_PREFIX="WARNING:"
LOG_ERROR_PREFIX="ERROR:"


ARANGODB_DB_BIN="arangodb/bin/arangod"
ARANGODB_DB_SH_BIN="arangodb/bin/arangosh"
ARANGODB_AUTHENTICATION="false"
ARANGODB_SERVER_ENDPOINT="tcp://127.0.0.1"
ARANGODB_SERVER_ENDPOINT_DEFAULT_PORT="8529"
ARANGODB_SERVER_ENDPOINT_CURRENT_PORT="8529"
ARANGODB_DIR="db"
ARANGODB_LOG_DIR="log"
ARANGODB_LOG_FILE="arangodb.log"
ARANGODB_PID_ID=-1
ARANGODB_SEED_SCRIPT="scripts/seed-arango-db.js"

TONOSSE_DIR="tonos-se"
TONOSSE_BIN="ton_node_startup"
TONOSSE_CONFIG="config.json"
TONOSSE_BLOCKCHAINCONFIG="blockchain.conf.json"
TONOSSE_CONFIG_TEMP="config-temp.json"
TONOSSE_PID_ID=-1
TONOSSE_CURRENT_PORT=40301
TONOSSE_DEFAULT_PORT=40301
TONOSSE_BLOCKCHAIN_DIR="workchains"
NGINX_CONF="distr/nginx/nginx.conf"
NGINX_RUNDIR="distr/nginx/"


TON_Q_DIR="ton-q-server"
TON_Q_LOG_DIR="log"
TON_Q_LOG_FILENAME="ton-q-server.log"
TON_Q_DATA_MUT="http://127.0.0.1"
TON_Q_DATA_HOT="http://127.0.0.1"
TON_Q_SLOW_QUERIES_MUT="http://127.0.0.1"
TON_Q_SLOW_QUERIES_HOT="http://127.0.0.1"
TON_Q_REQUESTS_MODE="rest"
TON_Q_REQUESTS_SERVER="http://127.0.0.1"
TON_Q_HOST="127.0.0.1"
TON_Q_PORT_DEFAULT="4000"
TON_Q_PORT="4000"
TON_Q_PID_ID=-1
TON_Q_TEST_DIR="distr/ton-client-js/packages/tests-node"


SKIP_CLEAR_CONSOLE="true"

################ MENU ##############
show_menu_delemeter()
{
    echo ""
    echo "##################TONOS SE CONTROL##################"
}

show_menu_level_1()
{
    echo "1 Start"
    echo "2 Change ports"
    echo "3 Clear database"
    echo "4 Exit"
}

show_menu_level_1_1()
{
    echo "1 Stop"
    echo "2 Restart"
    echo "3 Reset to zerostate and restart"
    echo "4 Run tests"
    echo "5 Stop and Exit"

}

show_menu_level_1_2()
{
    echo "1 Change arangodb port"
    echo "2 Reset arangodb port to default"
    echo "3 Change graphql port"
    echo "4 Reset graphql port to default"
    echo "5 Change tonos-se port"
    echo "6 Reset tonos-se port to default"
    echo "7 Previous menu"

}

show_menu_level_1_2_1()
{
    PORT_IS_FREE=$(ss -tln | grep $ARANGODB_SERVER_ENDPOINT_CURRENT_PORT)
    if [ -z "$PORT_IS_FREE" ]; then
        echo "$LOG_INFO_PREFIX port $ARANGODB_SERVER_ENDPOINT_CURRENT_PORT is free" 
    else
        echo "$LOG_WARNING_PREFIX port $ARANGODB_SERVER_ENDPOINT_CURRENT_PORT is busy"
    fi

    echo "1 Previous menu"
    echo "Type new port (now: $ARANGODB_SERVER_ENDPOINT_CURRENT_PORT)"
}

show_menu_level_1_2_3()
{
    PORT_IS_FREE=$(ss -tln | grep $TON_Q_PORT)
    if [ -z "$PORT_IS_FREE" ]; then
        echo "$LOG_INFO_PREFIX port $TON_Q_PORT is free" 
    else
        echo "$LOG_WARNING_PREFIX port $TON_Q_PORT is busy"
    fi

    echo "1 Previous menu"
    echo "Type new port (now: $TON_Q_PORT)"

}

show_menu_level_1_2_5()
{
    PORT_IS_FREE=$(ss -tln | grep $TONOSSE_CURRENT_PORT)
    if [ -z "$PORT_IS_FREE" ]; then
        echo "$LOG_INFO_PREFIX port $TONOSSE_CURRENT_PORT is free" 
    else
        echo "$LOG_WARNING_PREFIX port $TONOSSE_CURRENT_PORT is busy"
    fi

    echo "1 Previous menu"
    echo "Type new port (now: $TONOSSE_CURRENT_PORT)"

}



show_menu_info()
{
    case $MENU_LEVEL in
        1)
            ;;
        11)
            echo ""
            ARANGO_DB_IS_ACTIVE=$(pgrep -l arangod | grep $ARANGODB_PID_ID)
            if [ ! -z "$ARANGO_DB_IS_ACTIVE" ]; then
                echo "    Arangodb: $ARANGODB_SERVER_ENDPOINT:$ARANGODB_SERVER_ENDPOINT_CURRENT_PORT"
            fi

            TONOSSE_IS_ACTIVE=$(pgrep -l ton_node_startu | grep $TONOSSE_PID_ID)
            if [ ! -z "$TONOSSE_IS_ACTIVE" ]; then
                echo "    Tonos se: 0.0.0.0:$TONOSSE_CURRENT_PORT"
            fi

            TON_Q_IS_ACTIVE=$"pgrep -l q-server | grep $TON_Q_PID_ID"
            if [ ! -z "$TON_Q_IS_ACTIVE" ]; then
                CURRENT_IP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
                echo "    Q server: http://$CURRENT_IP:$TON_Q_PORT/graphql and http://$CURRENT_IP/graphql"
                echo "    TON live SE: http://$CURRENT_IP/landing"
            fi
            echo ""
            ;;
        12)
            ;;
        121)
            ;;
        123)
            ;;
    esac
}

show_menu()
{

    if [ "$SKIP_CLEAR_CONSOLE" = "false" ]; then
        clear -x
    fi

    if [ "$SKIP_CLEAR_CONSOLE" = "true" ]; then
        SKIP_CLEAR_CONSOLE="false"
    fi



    show_menu_delemeter
    show_menu_info

    case $MENU_LEVEL in
        1)
            show_menu_level_1
            MENU_LEVEL=1
            ;;
        11)
            show_menu_level_1_1
            MENU_LEVEL=11
            ;;
        12)
            show_menu_level_1_2
            MENU_LEVEL=12
            ;;
        121)
            show_menu_level_1_2_1
            MENU_LEVEL=121
            ;;
        123)
            show_menu_level_1_2_3
            MENU_LEVEL=123
            ;;
        125)
            show_menu_level_1_2_5
            MENU_LEVEL=125
            ;;
    esac
}

################ ARANGO DB ##############

start_arango_db()
{
    echo "$LOG_INFO_PREFIX Starting arangodb..."
    
    NEED_TO_SEED_ARANGO_DB="false";
    if [ ! -d "$ARANGODB_DIR" ]; then
        mkdir $ARANGODB_DIR
        NEED_TO_SEED_ARANGO_DB="true"
    fi

    if [ ! -d "$ARANGODB_LOG_DIR" ]; then
        mkdir $ARANGODB_LOG_DIR
    fi

    ARANGODB_SERVER_ENDPOINT_FULL="$ARANGODB_SERVER_ENDPOINT:$ARANGODB_SERVER_ENDPOINT_CURRENT_PORT"
    ARANGODB_RUN_COMMAND="$ARANGODB_DB_BIN --server.endpoint $ARANGODB_SERVER_ENDPOINT_FULL --database.directory $ARANGODB_DIR --server.authentication $ARANGODB_AUTHENTICATION --log.output file://$ARANGODB_LOG_DIR/$ARANGODB_LOG_FILE"

    # arangodb is running or stopped incorrect
    if [ -f "$ARANGODB_DIR/LOCK" ] || [ -f "$ARANGODB_DIR/engine-rocksdb/LOCK" ]; then
        ARANGODB_IS_RUNING=$(pgrep arango)
        if [ ! -z "$ARANGODB_IS_RUNING" ]; then
            echo "$LOG_ERROR_PREFIX arangodb already running, need to kill another process and restart this script, or delete $ARANGODB_DIR/LOCK and $ARANGODB_DIR/engine-rocksdb/LOCK manually"
            stop_arango_db
            exit
        fi

        if [ -f "$ARANGODB_DIR/LOCK" ]; then
            rm $ARANGODB_DIR/LOCK > /dev/null
        fi

        if [ -f "$ARANGODB_DIR/engine-rocksdb/LOCK" ]; then
            rm $ARANGODB_DIR/engine-rocksdb/LOCK > /dev/null
        fi
    fi  

    $ARANGODB_RUN_COMMAND  > /dev/null &
    ARANGODB_PID_ID=$!
    echo "$LOG_INFO_PREFIX Arangodb started, pid=$ARANGODB_PID_ID, endpoint=$ARANGODB_SERVER_ENDPOINT_FULL"

    if [ "$NEED_TO_SEED_ARANGO_DB" = "true" ]; then
        echo "$LOG_INFO_PREFIX Arangodb seed db ..."
        
        #wait while arango started
        sleep 10

        ARANGODB_SEED_COMMAND="$ARANGODB_DB_SH_BIN --server.endpoint tcp://127.0.0.1:$ARANGODB_SERVER_ENDPOINT_CURRENT_PORT --server.authentication $ARANGODB_AUTHENTICATION --javascript.execute $ARANGODB_SEED_SCRIPT  --javascript.startup-directory arangodb/usr/share/arangodb3/js"
        $ARANGODB_SEED_COMMAND

        echo "$LOG_INFO_PREFIX Arangodb seed ended"
    fi
}

stop_arango_db()
{
    echo "$LOG_INFO_PREFIX Stop arangodb..."

    ALL_JOBS=$(jobs -p)
    ARANGO_DB_PID_FIND=$(echo $ALL_JOBS | grep $ARANGODB_PID_ID)
    if [ ! -z "$ARANGO_DB_PID_FIND" ]; then
        kill -s 2 $ARANGODB_PID_ID > /dev/null
        echo "$LOG_INFO_PREFIX kill arangodb proc=$ARANGODB_PID_ID"
    else
        echo "$LOG_INFO_PREFIX nothing to stop"
    fi
    ARANGODB_PID_ID=-1
    echo "$LOG_INFO_PREFIX Arangodb stopped"
}

################ TONOS SE ##############

start_tonose()
{
    echo "$LOG_INFO_PREFIX Starting tonos-se..."

    pkill -9 nginx
    nginx -c $(pwd)/$NGINX_CONF -p $(pwd)/$NGINX_RUNDIR

    TONOSSE_DB_IP=$(cat $TONOSSE_DIR/$TONOSSE_CONFIG | jq .document_db.server -r | cut -d ":" -f 1)
    TONOSSE_DB_PORT=$(cat $TONOSSE_DIR/$TONOSSE_CONFIG | jq .document_db.server -r | cut -d ":" -f 2)
    
    TONOSSE_CHANGE_CONFIG_COMMAND="jq .document_db.server=\"$TONOSSE_DB_IP:$ARANGODB_SERVER_ENDPOINT_CURRENT_PORT\" $TONOSSE_DIR/$TONOSSE_CONFIG" 
    $TONOSSE_CHANGE_CONFIG_COMMAND > $TONOSSE_DIR/$TONOSSE_CONFIG_TEMP
    rm $TONOSSE_DIR/$TONOSSE_CONFIG
    mv $TONOSSE_DIR/$TONOSSE_CONFIG_TEMP $TONOSSE_DIR/$TONOSSE_CONFIG

    TONOSSE_CHANGE_CONFIG_COMMAND="jq .port=$TONOSSE_CURRENT_PORT $TONOSSE_DIR/$TONOSSE_CONFIG" 
    $TONOSSE_CHANGE_CONFIG_COMMAND > $TONOSSE_DIR/$TONOSSE_CONFIG_TEMP
    rm $TONOSSE_DIR/$TONOSSE_CONFIG
    mv $TONOSSE_DIR/$TONOSSE_CONFIG_TEMP $TONOSSE_DIR/$TONOSSE_CONFIG

    TONOSSE_RUN_COMMAND="./$TONOSSE_BIN --config $TONOSSE_CONFIG --blockchain-config $TONOSSE_BLOCKCHAINCONFIG"
    cd $TONOSSE_DIR
    $TONOSSE_RUN_COMMAND > /dev/null &
    cd - > /dev/null
    TONOSSE_PID_ID=$!
    
    TONOSSE_CURRENT_PORT=$(cat $TONOSSE_DIR/$TONOSSE_CONFIG | jq ".port")
    trap 'trap_kill_tonose' exit

    echo "$LOG_INFO_PREFIX tonos-se started, pid=$TONOSSE_PID_ID, port=$TONOSSE_CURRENT_PORT"
}

stop_tonose()
{
    echo "$LOG_INFO_PREFIX Stop tonos-se..."

    pkill -9 nginx

    ALL_JOBS=$(jobs -p)
    TONOSSE_PID_FIND=$(echo $ALL_JOBS | grep $TONOSSE_PID_ID)
    if [ ! -z "$TONOSSE_PID_FIND" ]; then
        kill -s 9 $TONOSSE_PID_ID > /dev/null
        echo "$LOG_INFO_PREFIX kill tonos-se proc=$TONOSSE_PID_ID"
    else
        echo "$LOG_INFO_PREFIX nothing to stop"
    fi
    TONOSSE_PID_ID=-1
    echo "$LOG_INFO_PREFIX tonos-se stopped"
}

# tonos-se don't close by -int signal for this script
trap_kill_tonose()
{
    if [ ! $TONOSSE_PID_ID -eq "-1" ]; then
        TONOSSE_PID_EXIST=$(pgrep ton_node_start | grep $TONOSSE_PID_ID )
        if [ ! -z $TONOSSE_PID_EXIST ]; then
            kill -s 9 $TONOSSE_PID_ID > /dev/null
        fi
    fi
}

update_tonosse_current_port()
{
    TONOSSE_CURRENT_PORT=$(cat $TONOSSE_DIR/$TONOSSE_CONFIG | jq ".port")
}

################ TON Q SERVER ##############

start_ton_q_server()
{
    echo "$LOG_INFO_PREFIX Starting ton-q-server..."

    export "Q_DATA_MUT=$TON_Q_DATA_MUT:$ARANGODB_SERVER_ENDPOINT_CURRENT_PORT"
    export "Q_DATA_HOT=$TON_Q_DATA_HOT:$ARANGODB_SERVER_ENDPOINT_CURRENT_PORT"
    export "Q_SLOW_QUERIES_MUT=$TON_Q_SLOW_QUERIES_MUT:$ARANGODB_SERVER_ENDPOINT_CURRENT_PORT"
    export "Q_SLOW_QUERIES_HOT=$TON_Q_SLOW_QUERIES_HOT:$ARANGODB_SERVER_ENDPOINT_CURRENT_PORT"
    export "Q_REQUESTS_MODE=$TON_Q_REQUESTS_MODE"
    export "Q_REQUESTS_SERVER=$TON_Q_REQUESTS_SERVER"
    export "Q_HOST=$TON_Q_HOST"
    export "Q_PORT=$TON_Q_PORT"

    TON_Q_COMMAND="node index.js --host 0.0.0.0"

    CURRENT_DIR=$(pwd)
    cd $TON_Q_DIR
    $TON_Q_COMMAND > $CURRENT_DIR/$TON_Q_LOG_DIR/$TON_Q_LOG_FILENAME &
    cd - > /dev/null
    TON_Q_PID_ID=$!
    
    echo "$LOG_INFO_PREFIX ton-q-server started, pid=$TON_Q_PID_ID"
}

stop_ton_q_server()
{
    echo "$LOG_INFO_PREFIX Stop ton-q-server..."

    ALL_JOBS=$(jobs -p)
    TON_Q_PID_ID_FIND=$(echo $ALL_JOBS | grep $TON_Q_PID_ID)
    if [ ! -z "$TON_Q_PID_ID_FIND" ]; then
        kill -s 9 $TON_Q_PID_ID > /dev/null
        echo "$LOG_INFO_PREFIX kill ton-q-server proc=$TON_Q_PID_ID"
    else
        echo "$LOG_INFO_PREFIX nothing to stop"
    fi
    TON_Q_PID_ID=-1
    echo "$LOG_INFO_PREFIX ton-q-server stopped"
}

################ FUNCTIONS ##############
start_all()
{
    start_arango_db
    start_tonose
    start_ton_q_server
}

stop_all()
{
    stop_ton_q_server
    stop_tonose
    stop_arango_db

    # wait while all is off
    sleep 5
}


clear_db()
{
    if [ -d "$ARANGODB_DIR" ]; then
        echo "remove $ARANGODB_DIR..."
        rm -rf $ARANGODB_DIR
        if [ ! -d "$ARANGODB_DIR" ]; then
            echo "removed $ARANGODB_DIR"
        fi
        sleep 1
    fi

    if [ -d "$TONOSSE_DIR/$TONOSSE_BLOCKCHAIN_DIR" ]; then
        echo "remove $TONOSSE_DIR/$TONOSSE_BLOCKCHAIN_DIR..."
        rm -rf $TONOSSE_DIR/$TONOSSE_BLOCKCHAIN_DIR
        if [ ! -d "$TONOSSE_DIR/$TONOSSE_BLOCKCHAIN_DIR" ]; then
            echo "removed $TONOSSE_DIR/$TONOSSE_BLOCKCHAIN_DIR"
        fi
        sleep 1
    fi
    sleep 1
}

change_arangodb_port()
{
    echo "chage arangodb port"
}

reset_arangodb_port()
{
    PORT_IS_FREE=$(ss -tln | grep $ARANGODB_SERVER_ENDPOINT_DEFAULT_PORT)
    if [ -z "$PORT_IS_FREE" ]; then
        ARANGODB_SERVER_ENDPOINT_CURRENT_PORT=$ARANGODB_SERVER_ENDPOINT_DEFAULT_PORT
        echo "$LOG_INFO_PREFIX Arangodb port $ARANGODB_SERVER_ENDPOINT_CURRENT_PORT"
        echo "$LOG_INFO_PREFIX done"
    else
        echo "$LOG_ERROR_PREFIX Port $ARANGODB_SERVER_ENDPOINT_DEFAULT_PORT already use"
    fi

    sleep 2
}

change_graphql_port()
{
    echo "chage graphql port"
}

reset_graphql_port()
{
    PORT_IS_FREE=$(ss -tln | grep $TON_Q_PORT_DEFAULT)
    if [ -z "$PORT_IS_FREE" ]; then
        TON_Q_PORT=$TON_Q_PORT_DEFAULT
        echo "$LOG_INFO_PREFIX Q server port $TON_Q_PORT"
        echo "$LOG_INFO_PREFIX done"
    else
        echo "$LOG_ERROR_PREFIX Port $TON_Q_PORT_DEFAULT already use"
    fi

    sleep 2
}

change_tonosel_port()
{
    echo "chage tonos-se port"
}

reset_tonose_port()
{
    PORT_IS_FREE=$(ss -tln | grep $TONOSSE_DEFAULT_PORT)
    if [ -z "$PORT_IS_FREE" ]; then
        TONOSSE_CURRENT_PORT=$TONOSSE_DEFAULT_PORT

        TONOSSE_CHANGE_CONFIG_COMMAND="jq .port=$TONOSSE_CURRENT_PORT $TONOSSE_DIR/$TONOSSE_CONFIG" 
        $TONOSSE_CHANGE_CONFIG_COMMAND > $TONOSSE_DIR/$TONOSSE_CONFIG_TEMP
        rm $TONOSSE_DIR/$TONOSSE_CONFIG
        mv $TONOSSE_DIR/$TONOSSE_CONFIG_TEMP $TONOSSE_DIR/$TONOSSE_CONFIG

        echo "$LOG_INFO_PREFIX Tonos-se port $TONOSSE_CURRENT_PORT"
        echo "$LOG_INFO_PREFIX done"
    else
        echo "$LOG_ERROR_PREFIX Port $TONOSSE_DEFAULT_PORT already use"
    fi

    sleep 2
}

run_tests()
{
    cd $TON_Q_TEST_DIR
    node run
    cd -
}

print_hello_message()
{
    echo "License:     MIT"
    echo "Source code: https://github.com/itgoldio/freeton-tonos-se-installer"
    echo "support RU:  https://t.me/itgoldio_support_ru"
    echo "support EN:  https://t.me/itgoldio_support_en"
    echo "created by:  https://itgold.io"
}

function to_int {
    local -i num="10#${1}"
    echo "${num}"
}

################ MAIN LOOP ##############

clear -x

update_tonosse_current_port

MENU_LEVEL=1
print_hello_message

# scrip clean for show hello mrssage
SKIP_CLEAR_CONSOLE="true"

show_menu

while :
do
  read INPUT_STRING
  case $INPUT_STRING in
	1)
        case $MENU_LEVEL in
            1)
            
                ARANGODB_PORT_IS_FREE=$(ss -tln | grep $ARANGODB_SERVER_ENDPOINT_CURRENT_PORT)
                TONOSSE_PORT_IS_FREE=$(ss -tln | grep $TONOSSE_CURRENT_PORT)
                TON_Q_PORT_IS_FREE=$(ss -tln | grep $TON_Q_PORT)

                if [ ! -z "$ARANGODB_PORT_IS_FREE" ]; then 
                    echo "$LOG_ERROR_PREFIX Can't start arangodb. Port $ARANGODB_SERVER_ENDPOINT_CURRENT_PORT is busy"
                fi

                if [ ! -z "$TONOSSE_PORT_IS_FREE" ]; then 
                    echo "$LOG_ERROR_PREFIX Can't start tonos-se. Port $TONOSSE_CURRENT_PORT is busy"
                fi

                if [ ! -z "$TON_Q_PORT_IS_FREE" ]; then 
                    echo "$LOG_ERROR_PREFIX Can't start q server. Port $TON_Q_PORT is busy"
                fi

                if [ ! -z "$ARANGODB_PORT_IS_FREE" ]; then 
                    echo "Change port or kill another process"
                    SKIP_CLEAR_CONSOLE="true"
                    show_menu
                    continue
                fi

                if [ ! -z "$TONOSSE_PORT_IS_FREE" ]; then 
                    echo "Change port or kill another process"
                    SKIP_CLEAR_CONSOLE="true"
                    show_menu
                    continue
                fi

                if [ ! -z "$TON_Q_PORT_IS_FREE" ]; then 
                    echo "Change port or kill another process"
                    SKIP_CLEAR_CONSOLE="true"
                    show_menu
                    continue
                fi

                start_all
                MENU_LEVEL=11
                show_menu
                ;;
            11)
                stop_all
                MENU_LEVEL=1
                show_menu
                ;;
            12)
                MENU_LEVEL=121
                show_menu
                continue
                ;;
            121)
                MENU_LEVEL=12
                show_menu
                ;;
            123)
                MENU_LEVEL=12
                show_menu
                ;; 
            125)
                MENU_LEVEL=12
                show_menu
                ;;   
        esac             
        ;;
	2)
        case $MENU_LEVEL in
            1)
                MENU_LEVEL=12
                show_menu
                ;;
            11)
                stop_all
                start_all
                show_menu
                ;;
            12)
                reset_arangodb_port
                show_menu
                ;;
        esac
        ;;
	3)
        case $MENU_LEVEL in
            1)
                clear_db
                show_menu
                ;;
            11)
                stop_all
                clear_db
                start_all
                show_menu
                ;;
            12)
                MENU_LEVEL=123
                show_menu
                continue
                ;;
        esac
        ;;
    4)
        case $MENU_LEVEL in
            1)
                exit
                ;;
            11)
                run_tests
                show_menu
                ;;
            12)
                reset_graphql_port
                show_menu
                ;;
        esac
        ;;
    5)
        case $MENU_LEVEL in
            11)
                stop_all
                exit
                ;;
            12)
                MENU_LEVEL=125
                show_menu
                continue
                ;;
        esac
        ;;
    6)
        case $MENU_LEVEL in
            12)
                reset_tonose_port
                show_menu
                ;;        
        esac
        ;;
    7)
        case $MENU_LEVEL in

            12)
                MENU_LEVEL=1
                show_menu
                ;;
        esac
        ;;
    esac

    if [ "$MENU_LEVEL" -eq "121" ]; then
        PORT=$INPUT_STRING
        PORT_NUM=$(to_int "${PORT}" 2>/dev/null)
        
        if (( $PORT_NUM < 1 || $PORT_NUM > 65535 )) ; then
            echo "$LOG_ERROR_PREFIX ${PORT} is not a valid port"
            continue
        fi

        PORT_IS_FREE=$(ss -tln | grep $PORT_NUM)
        if [ -z "$PORT_IS_FREE" ]; then
            echo "$LOG_INFO_PREFIX Port $PORT_NUM is free to use"
            ARANGODB_SERVER_ENDPOINT_CURRENT_PORT=$PORT_NUM
            echo "$LOG_INFO_PREFIX Set arangodb port $PORT_NUM"
            echo "$LOG_INFO_PREFIX done"
            sleep 2
            MENU_LEVEL=12
            show_menu
        else
            echo "$LOG_ERROR_PREFIX Port $PORT_NUM already use"
        fi

        sleep 2
    fi

    if [ "$MENU_LEVEL" -eq "123" ]; then
        PORT=$INPUT_STRING
        PORT_NUM=$(to_int "${PORT}" 2>/dev/null)
        
        if (( $PORT_NUM < 1 || $PORT_NUM > 65535 )) ; then
            echo "$LOG_ERROR_PREFIX ${PORT} is not a valid port"
            continue
        fi

        PORT_IS_FREE=$(ss -tln | grep $PORT_NUM)
        if [ -z "$PORT_IS_FREE" ]; then
            echo "$LOG_INFO_PREFIX Port $PORT_NUM is free to use"

            TON_Q_PORT=$PORT_NUM
            echo "$LOG_INFO_PREFIX Set q server port $PORT_NUM"
            echo "$LOG_INFO_PREFIX done"
            sleep 2
            MENU_LEVEL=12
            show_menu
        else
            echo "$LOG_ERROR_PREFIX Port $PORT_NUM already use"
        fi

        sleep 2
    fi

    if [ "$MENU_LEVEL" -eq "125" ]; then
        PORT=$INPUT_STRING
        PORT_NUM=$(to_int "${PORT}" 2>/dev/null)
        
        if (( $PORT_NUM < 1 || $PORT_NUM > 65535 )) ; then
            echo "$LOG_ERROR_PREFIX ${PORT} is not a valid port"
            continue
        fi

        PORT_IS_FREE=$(ss -tln | grep $PORT_NUM)
        if [ -z "$PORT_IS_FREE" ]; then
            echo "$LOG_INFO_PREFIX Port $PORT_NUM is free to use"

            TONOSSE_CURRENT_PORT=$PORT_NUM

            TONOSSE_CHANGE_CONFIG_COMMAND="jq .port=$TONOSSE_CURRENT_PORT $TONOSSE_DIR/$TONOSSE_CONFIG" 
            $TONOSSE_CHANGE_CONFIG_COMMAND > $TONOSSE_DIR/$TONOSSE_CONFIG_TEMP
            rm $TONOSSE_DIR/$TONOSSE_CONFIG
            mv $TONOSSE_DIR/$TONOSSE_CONFIG_TEMP $TONOSSE_DIR/$TONOSSE_CONFIG

            echo "$LOG_INFO_PREFIX Set tonos-se port $PORT_NUM"
            echo "$LOG_INFO_PREFIX done"
            sleep 2
            MENU_LEVEL=12
            show_menu
        else
            echo "$LOG_ERROR_PREFIX Port $PORT_NUM already use"
        fi

        sleep 2
    fi

done