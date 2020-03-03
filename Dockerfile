# A dockerfile must always start by importing the base image.
# We use the keyword 'FROM' to do that.
# In our example, we want import the python image.
# So we write 'python' for the image name and 'latest' for the version.
FROM pymesh/pymesh

# In order to launch our python code, we must import it into our image.
# We use the keyword 'COPY' to do that.
# The first parameter 'main.py' is the name of the file on the host.
# The second parameter '/' is the path where to put the file on the image.
# Here we put the file at the image root folder.

#RUN git clone --single-branch https://github.com/LPDI-EPFL/masif

# install necessary dependencies
RUN apt-get update && \
	apt-get install -y wget git unzip cmake vim
	
	


# DOWNLOAD/INSTALL APBS
RUN mkdir /install
WORKDIR /install
RUN git clone https://github.com/Electrostatics/apbs-pdb2pqr
WORKDIR /install/apbs-pdb2pqr
RUN git submodule init
RUN git submodule update
RUN cmake -DGET_MSMS=ON apbs
RUN make
RUN make install
RUN cp -r /install/apbs-pdb2pqr/apbs/externals/mesh_routines/msms/msms_i86_64Linux2_2.6.1 /root/msms/
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python2.7 get-pip.py

# INSTALL PDB2PQR
WORKDIR /install/apbs-pdb2pqr/pdb2pqr
RUN python2.7 scons/scons.py install

# Setup environment variables 
ENV MSMS_BIN /usr/local/bin/msms
ENV APBS_BIN /usr/local/bin/apbs
ENV MULTIVALUE_BIN /usr/local/share/apbs/tools/bin/multivalue
ENV PDB2PQR_BIN /root/pdb2pqr/pdb2pqr.py

# DOWNLOAD reduce (for protonation)
WORKDIR /install
RUN ["wget", "-O", "reduce.gz", "http://kinemage.biochem.duke.edu/php/downlode-3.php?filename=/../downloads/software/reduce31/reduce.3.23.130521.linuxi386.gz"]
RUN gunzip reduce.gz && \
	chmod 755 reduce && \
	cp reduce /usr/local/bin/

# Install python libraries
RUN pip3 install matplotlib 
RUN pip3 install ipython Biopython sklearn tensorflow==1.12 networkx open3d 
RUN pip install StrBioInfo 

# Clone masif
WORKDIR /
RUN git clone --single-branch https://github.com/LPDI-EPFL/masif

# We need to define the command to launch when we are going to run the image.
# We use the keyword 'CMD' to do that.
WORKDIR /masif
CMD [ "bash" ]

