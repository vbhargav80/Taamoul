//
//  AboutViewController.swift
//  MeditationTamoul
//
//  Created by AnilKumar Koya on 21/01/16.
//  Copyright © 2016 AnilKumar Koya. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet var aboutTextView : UITextView!
    //@IBOutlet var scrollView : UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 800)
        aboutTextView.text = "what is meditation \n\nما هو التأمل؟\n.التأمل هو طريقة لإسكات العقل الظاهر، و الإتصال بالعقل الباطن، حيث تسكن مفاهيُمنا العميقة\n\nو بما ان العقل الباطن هو المتحكم في هذه العمليه، نستطيع من خلال التأمل (إذا اردنا) تغير مفاهيمنا\n\nووجهات نظرنا و طريقة تعاملنا لبعض الامور، و في كثيرٍ من الاحيان على مستوى اعمق بكثير من العقل\n\n.الظاهر\n\nتجربة التأمل يصعب شرحها الى ان تجربها انت بنفسك. لكنها توصلك الى سلام داخلي و هذا ما يجذب الكثير\n\n.للمارسة التأمل\n\nwhat are the benefits of meditation?\n\t\tما هي فوائد التأمل؟\n\nبجانب الفوائد المرجوه من كل تأمل تمارسه من هذا البرنامج\nهناك فوائد اخرى سوف تلاحظها من خلال\n\nيجعلك اقل انزعاجا\n\n:ممارستك للتأمل و منها\n\n.تحسين التركيز\nالعقل الاكثر وضوحا\n\nالتأمل يساعدنا على ”الانفصال“ عن هذه الامور لكي لا نعطيها حجما\n\nو نفكر في لحظة الان. وليس في الماضي او المستقبل.\n\n“لان ”الآن“ هي كل ما لديك. و يجعلنا التأمل ان نرى الامور من منظور ”الصوره الاكبر\n\nصحة افضل\n\nهناك دراسات كثيره تشير الى\nفوائد التأمل الصحيه، و السبب كالتالي. التأمل يقلل من مستويات التوتر و\n\n.القلق. و بذلك يقلل الاجهاد و\nتتبعها فوائد صحيه\n\ndoes meditation conflict with our believes ?\n\t\tهل التأمل ممارسه دينيه؟\n\n،اجمل شئ في التامل هو ان العقيدة لا تمس\n\nالوعي الذي ياخذنا في اعماق النفس. و مع ذلك فان الكثير من الثقافات تأخذ ممارسة التامل بانها طريقة للنظر\n\nالتامل هو عن ”الوعي“\n\n.الي النفس و الذات.\nيقول االله تعالى ( وفي أنفسكم أفلا تبصرون ) صدق االله العظيم.\n\n\n\nhow to meditate? \n\t\tكيفية التأمل؟\n\nما عليك فعله هو ان تخصص ۳۰ دقيقه يوميا\n\n، اجلس او استلقي بطريقة مريحه .\n\nمن المهم ايضا ان تستخدم سماعات استيريو لهذا العمليه لان تقنية الموجات الصوتيه المصاحبة تعمل فقط\nمن\n\nهدئا\n\nو ان تختار مكانا\n\nخلال سماعات الإستيريو."
        aboutTextView.textAlignment = .Right
        aboutTextView.textColor = UIColor.whiteColor()
        aboutTextView.font = UIFont.systemFontOfSize(17)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
    }

    //MARK: Button Click Methods
    
    @IBAction func sideMenuButtonClick(sender: AnyObject)
    {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    @IBAction func signOutButtonClick(sender : UIButton){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("verifyCode")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("isVerified")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("isLogin")
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func foramButtonClick(sender : UIButton){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
