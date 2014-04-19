# -*- coding: utf-8 -*-
from flask import redirect, url_for, Flask
from StringIO import StringIO
import os
from smb import smb_structs
from flask import render_template
smb_structs.SUPPORT_SMB2 = False
from smb.SMBConnection import SMBConnection

import ConfigParser
cfg = ConfigParser.ConfigParser()
cfg.read('drive.cfg')

SERVER_IP = "202.175.9.5"
USERNAME = cfg.get("user", "username")
PASSWORD = cfg.get("user", "password")
MY_NAME = "ceclinux"
REMOTE_NAME = "ipm.edu.mo"
PORT = 445

app = Flask(__name__)


#如果是文件那么就下载
@app.route('/f/<path:filename>')
def show_file(filename):
    conn = SMBConnection(USERNAME, PASSWORD, MY_NAME, REMOTE_NAME, use_ntlm_v2=False)
    conn.connect(SERVER_IP, PORT)
    #This module implements a file-like class, StringIO, that reads and writes a string buffer (also known as memory files). See the description of file objects for operations (section File Objects). (For standard strings, see str and unicode.)
    temp_fh = StringIO()
#file_obj  A file-like object that has a write method. Data will be written continuously to file_obj until EOF is received from the remote service. In Python3, this file-like object must have a write method which accepts a bytes parameter.
    file_attributes, filesize = conn.retrieveFile('Share', '/ESAP/Hand-Out/' + filename, temp_fh)
    conn.close()
    #读取文件名字
    localfile = filename.split('/')[-1]
#存到服务器
    f = open(os.path.join(os.getcwd() + '/static/', localfile), 'w')
    f.write(temp_fh.getvalue())
#读取服务器的文件
    return redirect(url_for('static', filename=localfile), code=301)


@app.route('/favicon')
def show_favicon():
    return redirect(url_for('static', filename='favicon.ico'), code=301)


@app.route('/')
def render(files=None):
    return show_dir('.')


#如果是文件夹，那么就读取
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def show_dir(path):
    conn = SMBConnection(USERNAME, PASSWORD, MY_NAME, REMOTE_NAME, use_ntlm_v2=False)
    conn.connect(SERVER_IP, PORT)
    re = conn.listPath('Share',  os.path.join('/ESAP/Hand-Out/', path))
    conn.close()
    for i in re:
        i.link = os.path.join(path, i.filename)
    return render_template('hello.html', files=re)

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)

#app.run()
