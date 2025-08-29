import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Curriculum extends StatelessWidget {
  final List<Map<String, String>> btech2020 = [
    {
      "name": "Civil Engineering",
      "url": "https://soadu.box.com/s/e6ia21qtk1b2p0tcx390n5vwghfgdywj"
    },
    {
      "name": "Computer Science and Engineering",
      "url": "https://soadu.box.com/s/me58latyzy5ejmmc2xx5ullvows71ijc"
    },
    {
      "name": "Computer Science and Information Technology",
      "url": "https://soadu.box.com/s/oxkrsvq5rmbo9euogg2ytyk4uf4oovg6"
    },
    {
      "name": "Electrical and Electronics Engineering",
      "url": "https://soadu.box.com/s/6zetuwms1frx8jhcbbjdolzc797o4p47"
    },
    {
      "name": "Electrical Engineering",
      "url": "https://soadu.box.com/s/pllkpr28t4ccxmxrs5h7u2sxo1gtdxga"
    },
    {
      "name": "Electronics and Communication Engineering",
      "url": "https://soadu.box.com/s/7icaa4eesmioxc6795ljsjsj7e1dgarq"
    },
    {
      "name": "Mechanical Engineering",
      "url": "https://soadu.box.com/s/t8mog6hs8qt939iofwipr3kli8ragk65"
    },
  ];
  final List<Map<String, String>> btech2021 = [
    {
      "name": "Civil Engineering",
      "url": "https://soadu.box.com/s/nuboj5kq6ad3xsbjj5j05lufrrkh4g1q"
    },
    {
      "name": "Computer Science and Engineering",
      "url": "https://soadu.box.com/s/g6qlskhgr456ereujqgokewp8cp40a6l"
    },
    {
      "name": "Computer Science and Information Technology",
      "url": "https://soadu.box.com/s/efyatfs2gco8a8ne4up5qpunuzr04urp"
    },
    {
      "name": "Electrical and Electronics Engineering",
      "url": "https://soadu.box.com/s/jdv42d38ajre5qs3jmvkzkglws3xtlko"
    },
    {
      "name": "Electrical Engineering",
      "url": "https://soadu.box.com/s/1keb6m1511ti1jga89lngs0m1nodwucw"
    },
    {
      "name": "Electronics and Communication Engineering",
      "url": "https://soadu.box.com/s/lsz59w5jogcmh77icyd1c43f25atts7i"
    },
    {
      "name": "Mechanical Engineering",
      "url": "https://soadu.box.com/s/w2hxtahbq6nsoaucb90ck5lskf7jyxey"
    },
  ];
  final List<Map<String, String>> btech2022 = [
    {
      "name": "Civil Engineering",
      "url": "https://soadu.box.com/s/jplgtw95nqzhvmuhii3d1y7cjxapfeba"
    },
    {
      "name": "Computer Science and Engineering",
      "url": "https://soadu.box.com/s/sticiszyohrlrmdmj6owgykp20euc9rm"
    },
    {
      "name": "Computer Science and Information Technology",
      "url": "https://soadu.box.com/s/59irgdye4zckbhc0nqq1kb259d10ug05"
    },
    {
      "name": "CSE (AI and ML)",
      "url": "https://soadu.box.com/s/jjmhd0t714fox6ksfzv7u7ldn6p5kp5b"
    },
    {
      "name": "CSE (Cybersecurity)",
      "url": "https://soadu.box.com/s/4a7iolurxuys0xwqdqr9lywt3jj1p22v"
    },
    {
      "name": "CSE (Data Science)",
      "url": "https://soadu.box.com/s/ra62a369ij3xxn7pox0681mj9jqfwm4e"
    },
    {
      "name": "CSE (IoT)",
      "url": "https://soadu.box.com/s/rtmy94f4gztmpftylzmam7iyelq9qpmr"
    },
    {
      "name": "Electrical and Electronics Engineering",
      "url": "https://soadu.box.com/s/cocwae1fgplvluug674h5ppl19nsril9"
    },
    {
      "name": "Electrical Engineering",
      "url": "https://soadu.box.com/s/dci0zv7op92fp60zuzmmjnoa5ua3kiuc"
    },
    {
      "name": "Electronics and Communication Engineering",
      "url": "https://soadu.box.com/s/u10cddpgva4jzwaiqv6yqvt89ae63ffx"
    },
    {
      "name": "Mechanical Engineering",
      "url": "https://soadu.box.com/s/d60klw8yd9sjz2vav7i09iafvbxkyzuy"
    },
  ];
  final List<Map<String, String>> btech2023 = [
    {
      "name": "Civil Engineering",
      "url": "https://soadu.box.com/s/jekgix2vmmedzkym4kbns6lfiac9l8o1"
    },
    {
      "name": "Computer Science and Engineering",
      "url": "https://soadu.box.com/s/haugli75kmjtxsmxluez8oz6pihm0uhg"
    },
    {
      "name": "Computer Science and Information Technology",
      "url": "https://soadu.box.com/s/gogugnfj084cp4pcgyptheqbmfjl659m"
    },
    {
      "name": "CSE (AI and ML)",
      "url": "https://soadu.box.com/s/zw812g204sh4p9rjxis0q0ylbfx30cis"
    },
    {
      "name": "CSE (Cybersecurity)",
      "url": "https://soadu.box.com/s/5w4jcu3uxzrl0t275dnsmk92wuho06fs"
    },
    {
      "name": "CSE (Data Science)",
      "url": "https://soadu.box.com/s/1at5m2h8y6drehvga75p1f1ve6iz12hh"
    },
    {
      "name": "CSE (IoT)",
      "url": "https://soadu.box.com/s/if9t6rbihhl79rs688isg70h2ro33kc7"
    },
    {
      "name": "Electrical and Electronics Engineering",
      "url": "https://soadu.box.com/s/rydzrh9s0n636iq52dgs2kdj01mv07jh"
    },
    {
      "name": "Electrical Engineering",
      "url": "https://soadu.box.com/s/ph0l7tcw5pt6qen189e1w8i19kef967r"
    },
    {
      "name": "Electronics and Communication Engineering",
      "url": "https://soadu.box.com/s/tmbn8nszhf3py2v4y37c41joxji0t693"
    },
    {
      "name": "Mechanical Engineering",
      "url": "https://soadu.box.com/s/9jvx9h68nrn4ruxgtp45sr5a3hq4wmxi"
    },
  ];
  final List<Map<String, String>> btech2024 = [
    {
      "name": "Civil Engineering",
      "url": "https://soadu.app.box.com/s/zaziqohhh4jqq5ijtnxp33jku3cqftji"
    },
    {
      "name": "Computer Science and Engineering",
      "url": "https://soadu.app.box.com/s/eju8pru89jlehfmtezlikdiwlk048eq1"
    },
    {
      "name": "Computer Science and Information Technology",
      "url": "https://soadu.app.box.com/s/krmgnxbbre13r4w0a4olmpwahuw8qpwz"
    },
    {
      "name": "CSE (AI and ML)",
      "url": "https://soadu.app.box.com/s/dbbibpug0st5099j8lb3mpp8rheo3ahs"
    },
    {
      "name": "CSE (Cybersecurity)",
      "url": "https://soadu.app.box.com/s/vn1b8zrkwby1qon088qrxiju1za967gm"
    },
    {
      "name": "CSE (Data Science)",
      "url": "https://soadu.app.box.com/s/43i7dcbonfhumpkt6riahv6qoancdheq"
    },
    {
      "name": "CSE (IoT)",
      "url": "https://soadu.app.box.com/s/66ymcfo5axdzibkkqva8f3l2i0wduhll"
    },
    {
      "name": "Electrical and Electronics Engineering",
      "url": "https://soadu.app.box.com/s/9rjch04e6hnshh1oet4dipop2yfg44l6"
    },
    {
      "name": "Electrical Engineering",
      "url": "https://soadu.app.box.com/s/33tpe5g3gjywb2lpq54t14o3buaba3c1"
    },
    {
      "name": "Electronics and Communication Engineering",
      "url": "https://soadu.app.box.com/s/tby0olg35dlewb7avwvgx63xvv5xc7ri"
    },
    {
      "name": "Mechanical Engineering",
      "url": "https://soadu.box.com/s/2ulgiqbxepjuloumix2wnslz62akbxrp"
    },
  ];
  final List<Map<String, String>> mca = [
    {
      "name": "Admission Batch of 2023",
      "url": "https://soadu.app.box.com/s/g4kw0qtp1gi87d3aeio91ab7str5xgkm"
    },
    {
      "name": "Admission Batch of 2024",
      "url": "https://soadu.app.box.com/s/xpmol1a8gf8z4nbi2k63ru7bn1sclk94"
    },
    {
      "name": "Admission Batch of 2025",
      "url": "https://soadu.app.box.com/s/ho8s6xoy7a32bbq42p9wr7rzs9igm20k"
    },
  ];

  Future<void> _launchURL(String link) async {
    final Uri _url = Uri.parse(link);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  Widget _buildExpansionTile(String title, List<Map<String, String>> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final dept = items[index];
              return ListTile(
                title: Text(dept["name"]!),
                trailing: const Icon(Icons.open_in_new, color: Colors.blue),
                onTap: () => _launchURL(dept["url"]!),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Curriculum")),
      body: ListView(
        children: [
          _buildExpansionTile("B.Tech Admission batch of 2020", btech2020),
          _buildExpansionTile("B.Tech Admission batch of 2021", btech2021),
          _buildExpansionTile("B.Tech Admission batch of 2022", btech2022),
          _buildExpansionTile("B.Tech Admission batch of 2023", btech2023),
          _buildExpansionTile("B.Tech Admission batch of 2024", btech2024),
          _buildExpansionTile("MCA", mca),

        ],
      ),
    );
  }
}
