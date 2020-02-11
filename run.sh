#!/bin/bash

# docker variables
img_name=mib3oi_u14_v1:latest
container_name="mib3oi_u14_v1_container"
home_dir="/data001/vc.integrator"
export user_id="8100"
export group_id="8100"
opt_dns="--dns 156.147.1.1 --dns 165.243.17.15 --dns 10.158.14.11 --dns 8.8.8.8 --dns 8.8.4.4"


case $1 in
    check)
        ;;
    start)
        sudo docker run \
            -dit \
            --name ${container_name} ${opt_dns}\
            -e USER="vc.integrator" \
            -u ${user_id}:${group_id} \
            --workdir="${home_dir}" \
            -v /etc/group:/etc/group:ro \
            -v /etc/passwd:/etc/passwd:ro \
            -v /etc/shadow:/etc/shadow:ro \
            -v /etc/timezone:/etc/timezone:ro \
            -v /etc/localtime:/etc/localtime:ro \
            -v /etc/ssh:/etc/ssh:ro \
            -v ${home_dir}/.ssh:${home_dir}/.ssh \
            -v ${home_dir}/mirror:/${home_dir}/mirror \
            -v ${home_dir}/docker_test/mib3oi_source:/${home_dir}/mib3oi_source \
            ${img_name}
        ;;
    stop)
        sudo docker stop ${container_name}
        sudo docker rm -f ${container_name}
        ;;
    restart)
        sudo docker restart ${container_name}
        ;;
    exec)
        sudo docker exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -it ${container_name} bash
        ;;
    logs)
        sudo docker logs --tail 100 --follow --timestamps ${container_name}
        ;;
    *)
        echo "Usage: $0 [start|stop|restart|exec|logs]"
esac

exit $?

