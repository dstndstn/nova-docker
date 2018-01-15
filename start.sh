#!/bin/bash
#!/bin/bash

nohup /bin/bash ./process_submission.sh &
/usr/sbin/apache2ctl -D FOREGROUND
